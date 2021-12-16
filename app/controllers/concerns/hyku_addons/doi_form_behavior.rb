# frozen_string_literal: true
module HykuAddons
  module DOIFormBehavior
    extend ActiveSupport::Concern

    included do
      self.terms += [:doi]

      delegate :doi, to: :model
    end

    def primary_terms
      !Flipflop.doi_tab? && Flipflop.doi_minting? ? super << :doi : super
    end

    def secondary_terms
      super - [:doi]
    end
  end
end
