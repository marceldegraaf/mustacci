require 'yaml'
require 'hashie/mash'

module Mustacci

  class << self

    def log(message)
      $stdout.puts "\e[33m[#{Time.now}] #{message}\e[0m"
    end

    def config
      @configuration ||= Hashie::Mash.new(YAML.load(File.open('./config/mustacci.yml')))
    end

  end

end
