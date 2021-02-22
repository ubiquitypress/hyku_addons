# frozen_string_literal: true
module HykuAddons
  class SubjectService < HykuAddons::QaSelectService
    def initialize(model: nil, request: nil)
      super('subject', model: model, request: request)
    end
  end
end
