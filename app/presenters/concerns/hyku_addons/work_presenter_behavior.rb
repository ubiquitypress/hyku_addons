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
  end
end
