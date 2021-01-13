# frozen_string_literal: true
module HykuAddons
  class InstitutionService < Hyrax::QaSelectService
    def initialize(_authority_name = nil)
      super('institution')
    end
  end
end
