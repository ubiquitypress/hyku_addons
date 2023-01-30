# frozen_string_literal: true
module HykuAddons
  module DOI
    module DataCiteRegistrarBehavior
      private

      def doi_enabled_work_type?(_work)
        true
      end
    end
  end
end
