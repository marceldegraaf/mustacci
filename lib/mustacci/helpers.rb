module Mustacci
  module Helpers

    def info(*args)
      configuration.logger.info(*args)
    end

    def warn(*args)
      configuration.logger.warn(*args)
    end

    def debug(*args)
      configuration.logger.debug(*args)
    end
    alias debug puts

    def configuration
      Mustacci.configuration
    end

  end
end
