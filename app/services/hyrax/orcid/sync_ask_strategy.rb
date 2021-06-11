# frozen_string_literal: true

# Sync the the users details if they are the priamry user, otherwise create a notification
module Hyrax
  module Orcid
    class SyncAskStrategy
      include Hyrax::OrcidHelper

      def initialize(work, identity)
        @work = work
        @identity = identity
      end

      def perform
        if pimary_user?
          sync_now
        else
          notify
        end
      end

      protected

        def primary_user?
          @work.depositor == @identity.user.email
        end

        def sync_now
          Hyrax::Orcid::SyncAllStrategy.new(@work, @identity).perform
        end

        def notify

        end
    end
  end
end
