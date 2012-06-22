require 'mustacci/configuration'
require 'mustacci/helpers'
require 'mustacci/version'

module Mustacci

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end

end
