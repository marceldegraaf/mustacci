require 'mustacci/version'
require 'mustacci/configuration'
require 'mustacci/helpers'
require 'mustacci/database'
require 'mustacci/payload'
require 'mustacci/project'
require 'mustacci/build'

module Mustacci

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end

end
