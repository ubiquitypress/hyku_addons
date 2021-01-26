# frozen_string_literal: true
module HykuAddons
  class FunderService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('funder', model: model)
    end
  end
end
