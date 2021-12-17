# frozen_string_literal: true

module HykuAddons
  module DOIFormBehavior
    def primary_terms
      return super if Flipflop.doi_tab? && !Flipflop.doi_minting?

      super + [:doi]
    end
  end
end
