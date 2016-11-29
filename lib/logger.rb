class Logger

  def self.log(message, options = {})
    $redis = Redis.new(url: ENV['REDIS_URL'])
    output = ''
    if options[:generator].present?
      output << "[Zone: #{options[:generator].challenge.zone}"
      output << " - Domains: #{options[:generator].challenge.domains.join(", ")}] "
      $redis.set("#{options[:generator].challenge.token}_latest", message)
    end
    output << "----> #{message}"


    puts output unless ENV['ENVIRONMENT'] == 'test'
    return output
  end

end
