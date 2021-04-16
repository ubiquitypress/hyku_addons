# frozen_string_literal: true

module HykuAddons
  module WorkFactoryBehavior
    def self.for(resource:)
      work = Hyrax::Hirmeos::Client::Work.new
      work.title = resource.title
      work.uri = [{ uri: resource_url(resource), canonical: true },
                  { uri: frontend_resource_url(resource)},
                  { uri: "urn:uuid:#{resource.id}" }]
      work.type = "repository-work"
      work
    end

    def self.frontend_resource_url(work)
      work_types = current_account.google_scholarly_work_types
      work_types ||= []
      if work_types.include?(work.work_type) ? build_scholarly_link(work) : build_non_scholarly_link(work)
    end

    def self.build_scholarly_link(work)
      "https://#{current_account.cname.split("dashboard.").last}/work/sc/#{work.id}"
    end

    def self.build_non_scholarly_link(work)
      "https://#{current_account.cname.split("dashboard.").last}/work/ns/#{work.id}"
    end
  end
end
