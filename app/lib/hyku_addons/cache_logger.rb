# frozen_string_literal: true

module HykuAddons
  module CacheLogger
    def fetch(name, options = nil, &block)
      Rails.logger.info "[LogCacheKeys] Read: #{name}"
      super(name, options, &block)
    end

    def read(name, options = nil)
      Rails.logger.info "[LogCacheKeys] Read: #{name}"
      super(name, options)
    end

    def write(name, value, options = nil)
      Rails.logger.info "[LogCacheKeys] Write: #{name}"
      super(name, value, options)
    end
  end
end
