require 'sidekiq'
require_relative '../lib/logger'
require_relative '../lib/certificate_generator'
require_relative '../lib/cloudflare_challenge'
require_relative '../lib/acme_client_registration'
require_relative '../lib/provisioners/heroku'

class CloudflareChallengeWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false

  def perform(zone, domains, token, app_name, debug = true)
    Logger.log("Starting challenge creation on zone: #{zone}, with domains: #{domains}.")
    Logger.log("Debug is #{debug ? 'ON' : 'OFF'}")
    a = CloudflareChallenge.new(zone: zone,
                            domains: domains,
                            token: token,
                            client: AcmeClientRegistration.new(debug: debug).client)

    begin
      generator = CertificateGenerator.new(challenge: a)
      cert = generator.certificate
      Logger.log("Generated certificate", generator: generator)
      Provisioner::Heroku.new(app_name: app_name, certificate: cert).provision!
    rescue Exception => e
      Logger.log("Failed. Error given was #{e}")
    end
  end
end
