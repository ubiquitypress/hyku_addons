# frozen_string_literal: true
module HykuAddons
  class RelatedIdentifierTypeService < Hyrax::QaSelectService
    def initialize(_authority_name = nil)
      super('related_identifier_type')
    end
  end
end
