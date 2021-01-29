# frozen_string_literal: true
module HykuAddons
  class RefereedService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('refereed', model: model)
    end
  end
end
