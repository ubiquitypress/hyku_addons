# frozen_string_literal: true

require 'google/cloud/storage'

# Example:
# https://demo.ubiquityrepo-ah.website/concern/file_sets/d6facdbe-da76-47ef-8544-555b8acf0523?locale=en
#
# HykuAddons::FileSetSignedUrlService.new(file_set_id: 'd6facdbe-da76-47ef-8544-555b8acf0523').perform

module HykuAddons
  class FileSetSignedUrlService
    STORAGE_PATH_PREFIX = "fcrepo.binary.directory"

    def initialize(file_set_id:, bucket_name: ENV["FEDORA_BUCKET"])
      @bucket_name = bucket_name
      @file_set = FileSet.find(file_set_id)
    end

    def perform
      bucket = storage.bucket(@bucket_name)
      file = bucket.file(file_path)

      file.signed_url(signing_options)
    end

    protected

      def file_path
        [STORAGE_PATH_PREFIX, grouped_digest, digest].join("/")
      end

      def grouped_digest
        digest.split('').in_groups_of(2).first(3).map { |g| g.join }.join("/")
      end

      def digest
        @file_set.original_file.digest.first.to_s.split(':').last
      end

      def signing_options
        {
          method: "GET",
          expires: expires
        }
      end

      def expires
        (ENV["DOWNLOAD_LINK_EXP_MINUTES"] || 60).to_i * 60
      end

      def storage
        @_storage ||= Google::Cloud::Storage.new
      end
  end
end
