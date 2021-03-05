# frozen_string_literal: true

module HykuAddons
  module CollectionPresenterBehavior
    extend ActiveSupport::Concern

    include HykuAddons::PersonOrOrganizationPresenterBehavior

    delegate :contributor_display, :creator, :creator_json, to: :solr_document
  end
end
