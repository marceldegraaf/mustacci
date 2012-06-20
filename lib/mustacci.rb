module Mustacci

  def self.log(message)
    $stdout.puts "\e[33m[#{Time.now}] #{message}\e[0m"
  end

end
