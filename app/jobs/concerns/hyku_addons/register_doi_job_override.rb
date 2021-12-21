# frozen_string_literal: true

module HykuAddons
  module RegisterDOIJobOverride
    extend ActiveSupport::Concern

    included do
      rescue_from Hyrax::DOI::DataCiteClient::Error do |exception|
        Rails.logger.debug exception.inspect
        retry_job(wait: 5.minutes)
      end
    end
  end
end
