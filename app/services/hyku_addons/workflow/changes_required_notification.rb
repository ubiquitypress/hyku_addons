# frozen_string_literal: true
module HykuAddons
  module Workflow
    module ChangesRequiredNotification 
      private

        def message
          I18n.t('hyrax.notifications.workflow.changes_required.message', link: (link_to title, document_path),
          user: user.user_key, comment: comment)
        end
    end
  end
end
