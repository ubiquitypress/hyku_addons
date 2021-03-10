# frozen_string_literal: true
require "google/cloud/storage"

# s = HykuAddons::GoogleCloudSignedUrlService.new(bucket_name: ENV["FEDORA_BUCKET], filename: nil)
# s.perform
module HykuAddons
  class GoogleCloudSignedUrlService
    EXPIRES_IN = 5 * 60 # 5 minutes

    # The ID of your GCS bucket: bucket_name = "your-unique-bucket-name"
    # The ID of your GCS object: filename = "your-file-name"
    def initalize(bucket_name:, filename:)
      @bucket_name = bucket_name
      @filename = filename
    end

    def perform
      storage.signed_url @bucket_name, @filename, options
    end

    protected

      def options
        {
          method: "GET",
          expires: EXPIRES_IN,
          version: :v4
        }
      end

      def storage
        @storage ||= Google::Cloud::Storage.new
      end
  end
end
