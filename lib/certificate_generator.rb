class CertificateGenerator

  attr_reader :csr, :challenge, :certificate

  def initialize(options = {})
    @challenge = options[:challenge]

    @challenge.create_challenge_records
    sleep(60)
    @challenge.verify

    @csr = Acme::Client::CertificateRequest.new(names: @challenge.domains)
    @certificate = @challenge.client.new_certificate(csr)
  end
end
