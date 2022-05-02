# frozen_string_literal: true

module HykuAddons
  module ArrayFieldToSingleField
    extend ActiveSupport::Concern
    class_methods do
      def override_array_field_accessor(*fields)
        fields.each do |field|
          class_eval(
            "def #{field}
              super&.first || ''
            end"
          )
        end
      end
    end
  end
end
