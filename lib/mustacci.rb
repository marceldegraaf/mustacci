[ './lib', './config' ].each { |dir| $LOAD_PATH << dir }

require 'mustacci/campfire'
require 'mustacci/configuration'

module Mustacci

  class << self

    def configuration
      @configuration ||= Mustacci::Configuration.load
    end

  end

end
