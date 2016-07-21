class Challenge

  attr_reader :client, :authorization, :domain

  def initialize(options = {})
    @client = options[:client]
    @domain = options[:domain]
    @authorization = @client.authorize(domain: @domain)
  end

  def dns01
    @authorization.dns01
  end



end
