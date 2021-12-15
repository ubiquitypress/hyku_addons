# frozen_string_literal: true

# Remove the solr collection then destroy this record
module HykuAddons
  module NilEndpointOverride
    extend ActiveSupport::Concern

    def assign_attributes(_attr)
      false
    end
  end
end
