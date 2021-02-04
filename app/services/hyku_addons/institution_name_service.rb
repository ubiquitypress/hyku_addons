# frozen_string_literal: true
module HykuAddons
  class InstitutionNameService < Hyrax::QaSelectService
    def initialize(_authority_name = nil)
      super('institution_name')
    end
  end
end
