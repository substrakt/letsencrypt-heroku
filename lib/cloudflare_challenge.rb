class CloudflareChallenge

  class NoCloudflareAPIKey < StandardError; end;
  class NoCloudflareEmail < StandardError; end;

  def initialize
    raise NoCloudflareAPIKey if ENV['CLOUDFLARE_API_KEY'].blank?
    raise NoCloudflareEmail if ENV['CLOUDFLARE_EMAIL'].blank?
  end

end
