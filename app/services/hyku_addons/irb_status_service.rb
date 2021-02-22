# frozen_string_literal: true
module HykuAddons
  class IrbStatusService < HykuAddons::QaSelectService
    def initialize(model: nil, request: nil)
      super('irb_status', model: model, request: request)
    end
  end
end
