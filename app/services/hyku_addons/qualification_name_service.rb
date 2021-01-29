# frozen_string_literal: true
module HykuAddons
  class QualificationNameService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('qualification_name', model: model)
    end
  end
end
