require 'acme-client'

class AcmeClientRegistration

  class NoEmailError < StandardError; end;

  LIVE_ENDPOINT  = "https://acme-v01.api.letsencrypt.org/"

  attr_reader :endpoint, :client

  def initialize(options = {})
    raise NoEmailError if ENV['CONTACT_EMAIL'].nil?
    @endpoint = LIVE_ENDPOINT

    @client = Acme::Client.new(private_key: OpenSSL::PKey::RSA.new(4096), endpoint: @endpoint)
    registration = @client.register(contact: "mailto:#{ENV['CONTACT_EMAIL']}")
    registration.agree_terms
  end

end
