# frozen_string_literal: true
module HykuAddons
  class IrbStatusService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("irb_status", model: model, locale: locale)
    end
  end
end
