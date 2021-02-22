# frozen_string_literal: true
module HykuAddons
  class RefereedService < HykuAddons::QaSelectService
    def initialize(model: nil, request: nil)
      super('refereed', model: model, request: request)
    end
  end
end
