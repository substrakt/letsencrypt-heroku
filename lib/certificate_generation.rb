require 'openssl'
require 'acme-client'
require 'cloudflare'
require 'resolv'
require 'digest'
require 'httparty'
require_relative '../lib/challenge'
require 'sidekiq'

class CertificateGeneration

  HEROKU_BASE_URL = "https://api.heroku.com".freeze

  attr_reader :app_name, :debug, :subdomains, :domain, :token

  def initialize(domain, subdomains, debug, app_name, token)
    @app_name = app_name
    @debug = debug
    @subdomains = subdomains
    @domain = domain
    @token = token
    @client = acme_client
    set_status(:initialized)
  end

  def provision!
    set_status(:starting)

    Sidekiq.redis do |conn|
      conn.pipelined do
        conn.set("#{redis_key}_app_name", @app_name)
        conn.set("#{redis_key}_domain", @domain)
        conn.set("#{redis_key}_subdomains", @subdomains)
        conn.set("#{redis_key}_debug", @debug)
      end
    end

    set_status(:in_progress)
    registration = @client.register(contact: "mailto:#{ENV['CONTACT_EMAIL']}")
    registration.agree_terms
    cf = CloudFlare::connection(ENV['CLOUDFLARE_API_KEY'], ENV['CLOUDFLARE_EMAIL'])
    domains = [domain]
    domains << subdomains.split(',').map{|d| d << ".#{domain}"}

    domains.flatten.each do |single_domain|
      challenge = Challenge.new(client: @client, domain: single_domain).dns01
      begin
          cf.rec_new(domain, 'TXT', "_acme-challenge.#{single_domain}", challenge.record_content, 1)
      rescue => e
        set_error(e.message)
      else
        set_message('Successfuly added DNS record to CloudFlare')
        set_message('Sleeping for 1 minute while we wait for DNS to propagate.')
        sleep(60)
        challenge.request_verification
        set_message('Sleeping for 2 seconds while LE verifies our ownership.')
        sleep(2)
        if challenge.verify_status == 'valid'
          set_message('YAY! Validation successful. On to certificate generation.')
        else
          set_error('Oh no. Validation was not successful. Try again.')
        end
      end
    end

    csr = Acme::Client::CertificateRequest.new(names: domains.flatten)
    begin
      certificate = @client.new_certificate(csr)
    rescue Acme::Client::Error => e
      set_error(e.message)
    end
    deploy_certificate(certificate)


    set_message('Done')
    set_status(:success)
  end

  private

  def deploy_certificate(certificate)
    set_message('Deploying certificate to Heroku')
    headers = {
      "Accept": 'application/vnd.heroku+json; version=3.sni_ssl_cert',
      "Authorization": "Bearer #{ENV['HEROKU_OAUTH_KEY']}",
      "Content-Type": "application/json"
    }
    query = { enabled: true }.to_json
    HTTParty.patch("#{HEROKU_BASE_URL}/apps/#{@app_name}/features/http-sni", headers: headers, body: query)

    query = {
      "certificate_chain": certificate.fullchain_to_pem,
      "private_key": certificate.request.private_key.to_pem
    }.to_json
    response = HTTParty.post("#{HEROKU_BASE_URL}/apps/#{@app_name}/sni-endpoints", headers: headers, body: query)
    if response.code == 422
      sni_endpoints = HTTParty.get("#{HEROKU_BASE_URL}/apps/#{@app_name}/sni-endpoints", headers: headers)
      HTTParty.patch("#{HEROKU_BASE_URL}/apps/#{@app_name}/sni-endpoints/#{sni_endpoints.parsed_response[0]["id"]}", headers: headers, body: query)
    end
  end

  def redis_key
    @token
  end

  def set_status(status)
    Sidekiq.redis { |conn| conn.set("#{redis_key}_status", status) }
  end

  def set_error(error)
    set_status(:failed)
    Sidekiq.redis { |conn| conn.set("#{redis_key}_error", error) }
  end

  def set_message(message)
    Sidekiq.redis { |conn| conn.set("#{redis_key}_message", message) }
  end

  def acme_client
    Acme::Client.new(private_key: OpenSSL::PKey::RSA.new(4096), endpoint: endpoint)
  end

  def endpoint
    @debug.to_i == 1 ? 'https://acme-staging.api.letsencrypt.org/' : 'https://acme-v01.api.letsencrypt.org/'
  end

end
