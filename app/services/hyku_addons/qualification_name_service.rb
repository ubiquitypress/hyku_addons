# frozen_string_literal: true
module HykuAddons
  class QualificationNameService < HykuAddons::QaSelectService
    def initialize(model: nil, request: nil)
      super('qualification_name', model: model, request: request)
    end
  end
end
