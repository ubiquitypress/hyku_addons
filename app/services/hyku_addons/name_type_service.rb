# frozen_string_literal: true
module HykuAddons
  class NameTypeService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('name_type', model: model)
    end
  end
end
