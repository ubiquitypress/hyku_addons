# frozen_string_literal: true

require 'google/cloud/storage'

# Example:
# https://demo.ubiquityrepo-ah.website/concern/file_sets/d6facdbe-da76-47ef-8544-555b8acf0523?locale=en
#
# file = FileSet.find("d6facdbe-da76-47ef-8544-555b8acf0523").original_file
# HykuAddons::FileSignedUrlService.new(file: file).perform

module HykuAddons
  class FileSignedUrlService
    STORAGE_PATH_PREFIX = "fcrepo.binary.directory"

    def initialize(file:, bucket_name: ENV["FEDORA_BUCKET"])
      # It's impossible to test if we only use the class type, so the respond_to helps that
      raise ArgumentError, "Hydra::PCDM::File is required" unless file.is_a?(Hydra::PCDM::File) || file.respond_to?(:digest)

      @file = file
      @bucket_name = bucket_name
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
        digest.split('').in_groups_of(2).first(3).map(&:join).join("/")
      end

      def digest
        @file.digest.first.to_s.split(":").last
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
        @storage ||= Google::Cloud::Storage.new
      end
  end
end
