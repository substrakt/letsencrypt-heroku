class Logger

  def self.log(message, options = {})
    output = ''
    if options[:generator].present?
      output << "[Zone: #{options[:generator].challenge.zone}"
      output << " - Domains: #{options[:generator].challenge.domains.join(", ")}] "
    end
    output << "----> #{message}"
    puts output unless ENV['ENVIRONMENT'] == 'test'
    return output
  end

end
