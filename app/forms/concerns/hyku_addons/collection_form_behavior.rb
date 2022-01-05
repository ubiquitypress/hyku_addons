# frozen_string_literal: true
module HykuAddons
  module CollectionFormBehavior
    extend ActiveSupport::Concern

    include HykuAddons::PersonOrOrganizationFormBehavior

    included do
      extend HykuAddons::JsonifyFieldsService
    end

    class_methods do
      def model_attributes(form_params)
        super.tap do |attributes|
          jsonify_fields(attributes, fields, self)
        end
      end

      private

        def fields
          [:creator, :contributor]
        end
    end

    # User collections will error without this, as _title is used in for works and collections
    def schema_driven?
      false
    end
  end
end
