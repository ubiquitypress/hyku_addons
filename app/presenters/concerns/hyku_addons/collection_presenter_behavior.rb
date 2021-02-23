# frozen_string_literal: true

module HykuAddons
  module CollectionPresenterBehavior
    extend ActiveSupport::Concern

    include HykuAddons::PersonOrOrganizationPresenterBehavior

    delegate :contributor_display, :creator_display, to: :solr_document
  end
end
