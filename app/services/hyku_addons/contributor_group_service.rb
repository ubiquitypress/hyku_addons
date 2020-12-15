# frozen_string_literal: true
module HykuAddons
  class ContributorGroupService < Hyrax::QaSelectService
    def initialize(_authority_name = nil)
      super('contributor_group')
    end
  end
end
