# frozen_string_literal: true

# General bahaviors to be added to all works
module HykuAddons
  module WorkPresenterBehavior
    extend ActiveSupport::Concern

    include HykuAddons::PersonOrOrganizationPresenterBehavior

    included do
      include Hyrax::DOI::DOIPresenterBehavior
      include Hyrax::DOI::DataCiteDOIPresenterBehavior
    end

    def editor_list
      @editor_list ||= person_or_organization_list(:editor)
    end
  end
end

