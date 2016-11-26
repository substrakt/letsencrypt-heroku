require 'logger'

class CertificateGenerator

  attr_reader :csr, :challenge, :certificate

  def initialize(options = {})
    @challenge = options[:challenge]

    Logger.log('Creating challenge records', generator: self)
    @challenge.create_challenge_records
    Logger.log('Sleeping for 60 seconds', generator: self)
    sleep(60) unless ENV['ENVIRONMENT'] == 'test'
    @challenge.verify

    @csr = Acme::Client::CertificateRequest.new(names: @challenge.domains)
    @certificate = @challenge.client.new_certificate(csr)
  end
end
