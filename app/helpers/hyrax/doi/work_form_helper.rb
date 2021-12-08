# frozen_string_literal: true
module Hyrax
  module DOI
    module WorkFormHelper
      def form_tabs_for(form:)
        if Flipflop.doi_tab? && form.model_class.ancestors.include?(Hyrax::DOI::DOIBehavior)
          super.prepend("doi")
        else
          super
        end
      end
    end
  end
end
