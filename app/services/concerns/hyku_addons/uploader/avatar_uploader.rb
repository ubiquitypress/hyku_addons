# frozen_string_literal: true
module HykuAddons
  module Uploader
    module AvatarUploader
      extend ActiveSupport::Concern
      # this is similar to what is here
      # https://github.com/carrierwaveuploader/carrierwave/blob/1.x-stable/lib/carrierwave/compatibility/paperclip.rb#L74
      # but since the system folder is not created inside public folder in production
      # this is an attempt to fix it
      def store_dir
        Rails.root.join("public", "system", ":attachment", ":id").to_s
      end
    end
  end
end
