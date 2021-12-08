# frozen_string_literal: true
module Hyrax
  module DOI
    module DOIFormBehavior
      def primary_terms
        Flipflop.doi_tab? ? super : super + [:doi]
      end

      def self.build_permitted_params
        super.tap do |permitted_params|
          permitted_params << :doi unless Flipflop.doi_tab?
        end
      end
    end
  end
end
