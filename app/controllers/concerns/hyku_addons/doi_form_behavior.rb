# frozen_string_literal: true

module HykuAddons
  module DOIFormBehavior
    def primary_terms
      return super unless Flipflop.inline_doi? && Flipflop.doi_minting?

      super + [:doi]
    end
  end
end
