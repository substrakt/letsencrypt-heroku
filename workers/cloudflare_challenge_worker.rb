require 'sidekiq'
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
    puts "---> Generating challenge TXT records"
    a.create_challenge_records
    puts "---> Sleeping for 60 seconds"
    sleep(30)
    puts "---> Half way there..."
    sleep(30)
    puts "---> Verifying domain ownership"
    if a.verify
      puts "---> Successfully verified ownership"
    else
      puts "!---> Failed to verify ownership"
    end
  end
end
