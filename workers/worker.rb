require 'sidekiq'
require_relative '../lib/certificate_generation'

class Worker
  include Sidekiq::Worker

  sidekiq_options :retry => false

  def perform(domain, subdomains, debug, app_name, token)
    generation = CertificateGeneration.new(domain, subdomains, debug, app_name, token)
    generation.provision!
  end
end
