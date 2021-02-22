# frozen_string_literal: true
module HykuAddons
  class FunderService < HykuAddons::QaSelectService
    def initialize(model: nil, request: nil)
      super('funder', model: model, request: request)
    end
  end
end
