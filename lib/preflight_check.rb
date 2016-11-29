class PreflightCheck

  def initialize(options = {})
    @heroku_token     = options[:heroku_token]
    @cloudflare_token = options[:cloudflare_token]
    @cloudflare_email = options[:cloudflare_email]
  end

  def check_heroku
    headers = {
      "Accept": 'application/vnd.heroku+json; version=3',
      "Authorization": "Bearer #{@heroku_token}",
      "Content-Type": "application/json"
    }
    HTTParty.get("https://api.heroku.com/apps", headers: headers).code == 200
  end

  def check_cloudflare
     headers = {
       'X-Auth-Email': @cloudflare_email,
       'X-Auth-Key': @cloudflare_token,
       'Content-Type': 'application/json'
     }
    HTTParty.get("https://api.cloudflare.com/client/v4/user", headers: headers).code == 200
  end
end
