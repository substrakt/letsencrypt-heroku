require 'sidekiq'
require_relative '../lib/certificate_generation'

class Worker
  include Sidekiq::Worker

  sidekiq_options :retry => false

  def perform(domain, subdomains, debug, app_name, token, renew)
    generation = CertificateGeneration.new(domain, subdomains, debug, app_name, token, renew)
    generation.provision!
  end
end
