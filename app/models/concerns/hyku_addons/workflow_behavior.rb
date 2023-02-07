# frozen_string_literal: true

module HykuAddons
  module WorkflowBehavior
    extend ActiveSupport::Concern

    private

    def document_path
      host = Site.instance.account.cname
      protocol = Rails.env.development? || Rails.env.test? ? "http" : "https"
      work_type = document.model_name.plural
      "#{protocol}://#{host}/concern/#{work_type}/#{document.id}"
    end
  end
end
