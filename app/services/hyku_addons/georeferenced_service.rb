# frozen_string_literal: true
module HykuAddons
  class GeoreferencedService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('georeferenced', model: model)
    end
  end
end
