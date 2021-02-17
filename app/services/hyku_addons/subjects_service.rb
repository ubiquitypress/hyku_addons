# frozen_string_literal: true
module HykuAddons
  class SubjectsService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('subjects', model: model)
    end
  end
end
