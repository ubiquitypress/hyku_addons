# frozen_string_literal: true

require 'google/cloud/storage'

# Example:
#
# work = ActiveFedora::Base.find('04e13d46-4e4c-4268-89f2-b920038dd3ae')
# file = work.file_sets.first.original_file

# HykuAddons::GoogleCloudSignedUrlService.new(file: file).perform

module HykuAddons
  class GoogleCloudSignedUrlService
    EXCEPTION_MESSAGE = "Hydra::PCDM::File is required - work.file_sets.first.original_file"
    GOOGLE_CLOUD_STORAGE_FOLDER_PREFIX = "fcrepo.binary.directory"

    def initialize(bucket_name: ENV["FEDORA_BUCKET"], file:)
      @bucket_name = bucket_name
      @file = file

      raise EXCEPTION_MESSAGE unless @file.is_a?(Hydra::PCDM::File)
    end

    def perform
      bucket = storage.bucket(@bucket_name)
      file = bucket.file(file_path)

      file.signed_url(signing_options)
    end

    protected

      def file_path
        [GOOGLE_CLOUD_STORAGE_FOLDER_PREFIX, grouped_digest].join("/")
      end

      def grouped_digest
        [digest.split('').in_groups_of(2).first(3).map { |g| g.join }.join("/"), digest].join("/")
      end

      def digest
        @file.digest.first.to_s.split(':').last
      end

      def signing_options
        {
          method: "GET",
          expires: ENV["DOWNLOAD_LINK_EXP_MINUTES"].to_i * 60
        }
      end

      def storage
        @_storage ||= Google::Cloud::Storage.new
      end
  end
end
