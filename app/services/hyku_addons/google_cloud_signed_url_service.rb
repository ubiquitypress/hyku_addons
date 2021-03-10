# frozen_string_literal: true

require 'google/cloud/storage'

# work = ActiveFedora::Base.find('04e13d46-4e4c-4268-89f2-b920038dd3ae')
# fs = work.file_sets.first
# file = fs.original_file
# file.digest.first.to_s
# file.digest.first.to_s.split(':').last
# work.id_to_uri

# # this is using 4 pairs and not 3?
# ActiveFedora::Base.id_to_uri("fa8d674ef8fcb8e48821457d21a2476b2f2a5225")

## Working
#
# ENV["GOOGLE_CLOUD_PROJECT"] = 'advancinghyku'
# bucket_name = ENV["FEDORA_BUCKET"]
# ENV['GOOGLE_CLOUD_KEYFILE_JSON'] = ENV['GOOGLE_APPLICATION_CREDENTIALS']
# storage = Google::Cloud::Storage.new
# prefix = 'fcrepo.binary.directory'
# path = [prefix, "b8/d4/fb/b8d4fbfe87d67fc88eef11b51d0a2eb690454c49"].join("/")
# bucket = storage.bucket(bucket_name)
# file = bucket.file(path)
# file.signed_url(method: "GET", expires: 600)

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
