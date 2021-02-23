# frozen_string_literal: true
module HykuAddons
  class IrbStatusService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('irb_status', model: model)
    end
  end
end
