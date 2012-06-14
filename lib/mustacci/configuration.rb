require 'hashie/mash'
require 'yaml'

module Mustacci
  class Configuration

    class << self

      def load
        return Hashie::Mash.new(YAML.load(File.open(path))['mustacci'])
      end

      def path
        'config/mustacci.yml'
      end

    end

  end
end
