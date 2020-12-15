# frozen_string_literal: true
module HykuAddons
  class QualificationNameService < Hyrax::QaSelectService
    def initialize(_authority_name = nil)
      super('qualification_name')
    end
  end
end
