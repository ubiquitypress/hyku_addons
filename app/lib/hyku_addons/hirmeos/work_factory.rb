# frozen_string_literal: true
module HykuAddons
  module Hirmeos
    class WorkFactory
      def self.for(resource:)
        work = Hyrax::Hirmeos::Client::Work.new
        work.title = resource.title
        work.uri = [{ uri: resource_url(resource) },
                    { uri: build_scholarly_link(resource) },
                    { uri: build_non_scholarly_link(resource) },
                    { uri: "urn:uuid:#{resource.id}", canonical: true }]
        work.type = "repository-work"
        work
      end

      def self.resource_url(work)
        Rails.application.routes.url_helpers.polymorphic_url(work)
      end

      def self.build_scholarly_link(work)
        "https://#{current_account.frontend_url}/work/sc/#{work.id}"
      end

      def self.build_non_scholarly_link(work)
        "https://#{current_account.frontend_url}/work/ns/#{work.id}"
      end

      def self.current_account
        Site.account
      end
    end
  end
end
