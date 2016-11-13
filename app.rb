require 'sinatra'
require 'dotenv'
require 'sidekiq'
Dotenv.load

require_relative 'workers/worker'

post '/certificate_request' do
  status 403 and return unless params['auth_token'] == ENV['AUTH_TOKEN']
  if params_valid?
    status 200
  else
    status 422
  end
end

private

def params_valid?
  params["domains"].present? && params["heroku_app_name"].present? && params["zone"].present?
end

# get '/certificate_generation/new/:domain' do
#   authenticate!
#   token = SecureRandom.hex
#   Worker.perform_async(params[:domain], params[:subdomains], params[:debug], params[:app_name], token)
#   content_type :json
#
#   { status_path: "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}/certificate_generation/#{token}" }.to_json
# end
#
# get '/certificate_generation/:token' do
#   authenticate!
#   content_type :json
#
#   pipe = Sidekiq.redis do |conn|
#     conn.pipelined do
#       conn.get("#{params[:token]}_status")
#       conn.get("#{params[:token]}_error")
#       conn.get("#{params[:token]}_domain")
#       conn.get("#{params[:token]}_subdomains")
#       conn.get("#{params[:token]}_message")
#     end
#   end
#
#   {
#     token:      params[:token],
#     status:     pipe[0],
#     error:      pipe[1],
#     domain:     pipe[2],
#     subdomains: pipe[3].to_s.split(','),
#     message:    pipe[4]
#   }.to_json
# end

private

def authenticate!
  unless (params[:auth_token] == ENV['AUTH_TOKEN'])
    halt 403, 'Not authenticated'
  end

end
