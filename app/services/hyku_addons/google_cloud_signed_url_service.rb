# frozen_string_literal: true

require 'google/cloud/storage'

module HykuAddons
  class GoogleCloudSignedUrlService
    def initalize(bucket_name:, filename:)
      @bucket_name = bucket_name
      @filename = filename
    end

    def perform
      bucket = storage.bucket(@bucket_name)
      file = bucket.file(@filename)

      file.signed_url(options)
    end

    protected

      def options
        {
          method: "GET",
          expires: ENV["DOWNLOAD_LINK_EXP_MINUTES"] * 60
        }
      end

      def storage
        @storage ||= Google::Cloud::Storage.new
      end
  end
end
