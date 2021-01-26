# frozen_string_literal: true
module HykuAddons
  class RelationTypeService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('relation_type', model: model)
    end
  end
end
