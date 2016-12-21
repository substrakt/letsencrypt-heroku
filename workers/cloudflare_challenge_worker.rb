require 'sidekiq'
require_relative '../lib/logger'
require_relative '../lib/certificate_generator'
require_relative '../lib/cloudflare_challenge'
require_relative '../lib/acme_client_registration'
require_relative '../lib/provisioners/heroku'

class CloudflareChallengeWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false

  def perform(zone, domains, token, app_name, debug = true, cloudflare = {}, heroku = {})
    $redis = Redis.new(url: ENV['REDIS_URL'])
    $redis.setex("status_#{token}", 3600, "started")
    Logger.log("Starting challenge creation on zone: #{zone}, with domains: #{domains}.")
    Logger.log("Debug is #{debug ? 'ON' : 'OFF'}")
    a = CloudflareChallenge.new(zone: zone,
                            domains: domains,
                            token: token,
                            email: cloudflare["email"],
                            api_key: cloudflare["api_key"],
                            client: AcmeClientRegistration.new(debug: debug).client)

    begin
      generator = CertificateGenerator.new(challenge: a)
      cert = generator.certificate
      Logger.log("Generated certificate", generator: generator)
      Provisioner::Heroku.new(app_name: app_name, certificate: cert, oauth_key: heroku["heroku"]["oauth_key"]).provision!
      $redis.setex("status_#{token}", 3600, "finished")
    rescue Exception => e
      Logger.log("Failed. Error given was #{e}")
      $redis.setex("status_#{token}", 3600, "error")
      $redis.setex("latest_#{token}", 3600, e)
    end
  end
end
