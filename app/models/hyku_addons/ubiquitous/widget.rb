module HykuAddons
  module Ubiquitous
    class Widget < ApplicationRecord
      validates :name, presence: true

      belongs_to :container, required: true

      before_create :set_uuid

      private

      def set_uuid
        self.uuid ||= SecureRandom.uuid
      end
    end
  end
end
