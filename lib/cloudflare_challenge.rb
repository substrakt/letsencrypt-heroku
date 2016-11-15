class CloudflareChallenge

  class NoCloudflareAPIKey < StandardError; end;
  class NoCloudflareEmail < StandardError; end;

  attr_reader :zone, :domains, :client, :challenges

  def initialize(options = {})
    raise NoCloudflareAPIKey if ENV['CLOUDFLARE_API_KEY'].blank?
    raise NoCloudflareEmail  if ENV['CLOUDFLARE_EMAIL'].blank?

    @zone    = options[:zone]
    @domains = options[:domains]
    @client  = options[:client]
    @challenges = @domains.map do |domain|
      Challenge.new(client: @client, domain: domain)
    end
  end

  def create_challenge_records
    cf = CloudFlare::connection(ENV['CLOUDFLARE_API_KEY'], ENV['CLOUDFLARE_EMAIL'])
    @challenges.each do |challenge|
      cf.rec_new(@zone, 'TXT', "_acme-challenge.#{challenge.domain}", challenge.dns01.record_content, 1)
    end
    @domains
  end

  # def verify
  #   challenge.request_verification
  # end

end
