# frozen_string_literal: true
module HykuAddons
  class WorkFactory
    def self.for(resource:)
      work = Hyrax::Hirmeos::Client::Work.new
      work.title = resource.title
      work.uri = [{ uri: resource_url(resource), canonical: true },
                  { uri: frontend_resource_url(resource) },
                  { uri: "urn:uuid:#{resource.id}" }]
      work.type = "repository-work"
      work
    end

    def self.resource_url(work)
      Rails.application.routes.url_helpers.polymorphic_url(work)
    end

    def self.frontend_resource_url(work)
      work_types = current_account.google_scholarly_work_types
      work_types ||= []
      work_types.include?(work.model_name.name.to_s) ? build_scholarly_link(work) : build_non_scholarly_link(work)
    end

    def self.build_scholarly_link(work)
      "https://#{current_account.cname}/work/sc/#{work.id}"
    end

    def self.build_non_scholarly_link(work)
      "https://#{current_account.cname}/work/ns/#{work.id}"
    end

    def self.current_account
      Site.account
    end
  end
end
