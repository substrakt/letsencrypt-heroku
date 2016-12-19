require_relative 'logger'

class CertificateGenerator

  attr_reader :csr, :challenge, :certificate

  def initialize(options = {})
    @challenge = options[:challenge]

    Logger.log('Creating challenge records', generator: self)
    @challenge.create_challenge_records
    Logger.log('Sleeping for 120 seconds', generator: self)
    sleep(120) unless ENV['ENVIRONMENT'] == 'test'
    @challenge.verify

    @csr = Acme::Client::CertificateRequest.new(names: @challenge.domains)
    @certificate = @challenge.client.new_certificate(csr)
  end
end
