class AcmeClientRegistration

  def initialize
    @client = Acme::Client.new(private_key: OpenSSL::PKey::RSA.new(4096), endpoint: 'https://acme-staging.api.letsencrypt.org/')
  end
end
