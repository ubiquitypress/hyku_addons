# frozen_string_literal: true
module HykuAddons
  module Workflow
    module PendingReviewNotification
      private

      def message
       I18n.t('hyrax.notifications.workflow.pending_review.message', link: (link_to title, document_path),
                                                                user: user.user_key, comment: comment)
     end
    end
  end
end
