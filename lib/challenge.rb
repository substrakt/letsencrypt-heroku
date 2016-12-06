class Challenge

  attr_reader :client, :authorization, :domain, :dns01

  def initialize(options = {})
    @client = options[:client]
    @domain = options[:domain]
    @authorization = @client.authorize(domain: @domain)
    @dns01 = @authorization.dns01
  end

  def status
    @dns01
  end
end
