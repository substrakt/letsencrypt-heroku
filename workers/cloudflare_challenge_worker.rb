require 'sidekiq'
require_relative '../lib/certificate_generator'
require_relative '../lib/cloudflare_challenge'
require_relative '../lib/acme_client_registration'

class CloudflareChallengeWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false

  def perform(zone, domains, token, debug = true)
    puts "---> Starting challenge creation on zone: #{zone}, with domains: #{domains}."
    puts "---> Debug is #{debug ? 'ON' : 'OFF'}"
    a = CloudflareChallenge.new(zone: zone,
                            domains: domains,
                            token: token,
                            client: AcmeClientRegistration.new(debug: debug).client)

    begin
      cert = CertificateGenerator.new(challenge: a).certificate
      # Pass these in to the heroku app
      private_key = cert.private_key
      certificate_url = cert.url
      # WOO!
    rescue Exception => e
      puts "Failed. Error given was #{e}"
    end
  end
end
