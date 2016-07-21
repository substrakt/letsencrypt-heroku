require 'sidekiq'
require 'openssl'
require 'acme-client'
require 'cloudflare'
require 'resolv'
require 'digest'
require 'httparty'
require_relative '../lib/challenge'
class Worker
  include Sidekiq::Worker

  sidekiq_options :retry => false

  def perform(domain, subdomains, debug, app_name)
    private_key = OpenSSL::PKey::RSA.new(4096)
    if debug
      endpoint = 'https://acme-staging.api.letsencrypt.org/'
    else
      endpoint = 'https://acme-v01.api.letsencrypt.org/'
    end

    client = Acme::Client.new(private_key: private_key, endpoint: endpoint)
    registration = client.register(contact: "mailto:#{ENV['CONTACT_EMAIL']}")
    registration.agree_terms
    cf = CloudFlare::connection(ENV['CLOUDFLARE_API_KEY'], ENV['CLOUDFLARE_EMAIL'])
    domains = [domain]
    domains << subdomains.split(',').map{|d| d << ".#{domain}"}

    domains.flatten.each do |single_domain|
      challenge = Challenge.new(client: client, domain: single_domain).dns01
      begin
          cf.rec_new(domain, 'TXT', "_acme-challenge.#{single_domain}", challenge.record_content, 1)
      rescue => e
          puts e.message # error message
      else
        puts '---> Successfuly added DNS record'
        puts '---> Sleeping for 1 minute while we wait for DNS to propagate.'
        sleep(60)
        challenge.request_verification
        puts '---> Sleeping for 2 seconds while LE verifies our ownership.'
        sleep(2)
        if challenge.verify_status == 'valid'
          puts '---> YAY! Validation successful. On to certificate generation.'
        else
          return '---> Oh no. Validation was not successful. Try again.'
        end
      end
    end

    csr = Acme::Client::CertificateRequest.new(names: domains.flatten)
    begin
      certificate = client.new_certificate(csr)
    rescue Acme::Client::Error::RateLimited
      return "---> This domain doesn't need renewing. Go away."
    end
    puts '---> Got certificate. Let\'s put it on Heroku.'


    headers = {
      "Accept": 'application/vnd.heroku+json; version=3.sni_ssl_cert',
      "Authorization": "Bearer #{ENV['HEROKU_OAUTH_KEY']}",
      "Content-Type": "application/json"
    }

    query = {
      enabled: true
    }.to_json
    HTTParty.patch("https://api.heroku.com/apps/#{app_name}/features/http-sni", headers: headers, body: query)

    query = {
      "certificate_chain": certificate.fullchain_to_pem,
      "private_key": certificate.request.private_key.to_pem
    }.to_json
    response = HTTParty.post("https://api.heroku.com/apps/#{app_name}/sni-endpoints", headers: headers, body: query)
    if response.code == 422
      sni_endpoints = HTTParty.get("https://api.heroku.com/apps/#{app_name}/sni-endpoints", headers: headers)
      response = HTTParty.patch("https://api.heroku.com/apps/#{app_name}/sni-endpoints/#{sni_endpoints.parsed_response[0]["id"]}", headers: headers, body: query)
    end
  end
end
