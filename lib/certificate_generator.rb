class CertificateGenerator

  attr_reader :csr, :challenge, :certificate

  def initialize(options = {})
    @challenge = options[:challenge]

    puts "[#{@challenge.domains} in #{@challenge.zone}] ---> Creating challenge records"
    @challenge.create_challenge_records
    puts "[#{@challenge.domains} in #{@challenge.zone}] ---> Sleeping for 60 seconds."
    # sleep(60) unless ENV['ENVIRONMENT'] == 'test'
    @challenge.verify

    @csr = Acme::Client::CertificateRequest.new(names: @challenge.domains)
    @certificate = @challenge.client.new_certificate(csr)
  end
end
