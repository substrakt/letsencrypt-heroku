class CloudflareChallenge

  class NoCloudflareAPIKey < StandardError; end;
  class NoCloudflareEmail < StandardError; end;

  attr_reader :zone, :domains

  def initialize(options = {})
    raise NoCloudflareAPIKey if ENV['CLOUDFLARE_API_KEY'].blank?
    raise NoCloudflareEmail  if ENV['CLOUDFLARE_EMAIL'].blank?

    @zone    = options[:zone]
    @domains = options[:domains]
  end

end
