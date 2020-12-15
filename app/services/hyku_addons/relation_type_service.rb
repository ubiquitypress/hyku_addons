# frozen_string_literal: true
module HykuAddons
  class RelationTypeService < Hyrax::QaSelectService
    def initialize(_authority_name = nil)
      super('relation_type')
    end
  end
end
