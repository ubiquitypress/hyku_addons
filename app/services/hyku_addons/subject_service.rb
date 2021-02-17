# frozen_string_literal: true
module HykuAddons
  class SubjectService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('subject', model: model)
    end
  end
end
