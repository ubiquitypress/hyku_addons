# frozen_string_literal: true

module HykuAddons
  module PortableGenericBehavior
    extend ActiveSupport::Concern

    def portable_object
      "Generic Portable"
      arguments[0]
    rescue
      nil
    end
  end
end
