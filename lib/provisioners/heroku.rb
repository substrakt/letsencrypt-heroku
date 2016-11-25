require 'httparty'
module Provisioner
  class Heroku

    HEROKU_BASE_URL = "https://api.heroku.com".freeze

    attr_reader :headers, :query

    def initialize(options = {})
      @certificate = options[:certificate]
      @app_name    = options[:app_name]

      @headers = {
        "Accept": 'application/vnd.heroku+json; version=3.sni_ssl_cert',
        "Authorization": "Bearer #{ENV['HEROKU_OAUTH_KEY']}",
        "Content-Type": "application/json"
      }

      @query = {
        "certificate_chain": @certificate.fullchain_to_pem,
        "private_key": @certificate.request.private_key.to_pem
      }.to_json
    end

    def provision!
      puts '---> Provisioning Heroku application with new certificate'
      HTTParty.patch("#{HEROKU_BASE_URL}/apps/#{@app_name}/features/http-sni", headers: @headers, body: {enabled: true}.to_json)
      puts "---> Uploading new certificate"
      response = HTTParty.post("#{HEROKU_BASE_URL}/apps/#{@app_name}/sni-endpoints", headers: @headers, body: @query)
      if response.code == 422
        if JSON.parse(response.body)["id"] == 'invalid_params'
          puts "---> The application must be using Hobby or Professional dynos for SSL"
          return false
        else
          puts "---> Certificate already exists. Replacing with new one"
          sni_endpoints = HTTParty.get("#{HEROKU_BASE_URL}/apps/#{@app_name}/sni-endpoints", headers: @headers)
          HTTParty.patch("#{HEROKU_BASE_URL}/apps/#{@app_name}/sni-endpoints/#{sni_endpoints.parsed_response[0]["id"]}", headers: @headers, body: @query)
          return true
        end
      end
      puts "---> Heroku response: #{response.body}"
      return true
    end

  end
end
