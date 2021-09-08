# frozen_string_literal: true

module HykuAddons
  module WorkflowBehavior
    extend ActiveSupport::Concern

    private

    def document_path
      key = document.model_name.singular_route_key
      Rails.application.routes.url_helpers.send(key + "_url", document.id, host: Site.instance.account.cname, protocol: :https)
    end
  end
end
