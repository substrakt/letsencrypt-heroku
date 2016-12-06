require_relative 'challenge'
require 'cloudflare'

class CloudflareChallenge

  attr_reader :zone, :domains, :client, :challenges, :token, :email, :api_key

  def initialize(options = {})
    @email   = options[:email]
    @api_key = options[:api_key]

    @zone    = options[:zone]
    @domains = options[:domains]
    @client  = options[:client]
    @token   = options[:token]
    @challenges = @domains.map do |domain|
      Challenge.new(client: @client, domain: domain)
    end
  end

  def create_challenge_records
    cf = CloudFlare::connection(@api_key, @email)
    @challenges.each do |challenge|
      cf.rec_new(@zone, 'TXT', "_acme-challenge.#{challenge.domain}", challenge.dns01.record_content, 1)
    end
    @domains
  end

  def verify
    @challenges.map do |challenge|
      challenge.dns01.request_verification
    end.uniq[0]
  end

end
