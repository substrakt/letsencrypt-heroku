class CloudflareChallenge

  class NoCloudflareAPIKey < StandardError; end;
  class NoCloudflareEmail < StandardError; end;

  attr_reader :zone, :domains, :client

  def initialize(options = {})
    raise NoCloudflareAPIKey if ENV['CLOUDFLARE_API_KEY'].blank?
    raise NoCloudflareEmail  if ENV['CLOUDFLARE_EMAIL'].blank?

    @zone    = options[:zone]
    @domains = options[:domains]
    @client  = options[:client]
  end

  def create_challenge_records
    cf = CloudFlare::connection(ENV['CLOUDFLARE_API_KEY'], ENV['CLOUDFLARE_EMAIL'])
    @domains.each do |domain|
      challenge = Challenge.new(client: @client, domain: domain).dns01
      cf.rec_new(@zone, 'TXT', "_acme-challenge.#{domain}", challenge.record_content, 1)
    end
  end

end
