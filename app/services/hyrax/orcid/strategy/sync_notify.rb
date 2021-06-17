# frozen_string_literal: true

# Sync the the users details if they are the priamry user, otherwise create a notification
module Hyrax
  module Orcid
    module Strategy
      class SyncNotify
        include Hyrax::Orcid::UrlHelper

        def initialize(work, identity)
          @work = work
          @identity = identity
        end

        def perform
          if primary_user?
            publish_work
          else
            notify
          end
        end

        protected

          def primary_user?
            depositor == @identity.user
          end

          def publish_work
            Hyrax::Orcid::OrcidWorkService.new(@work, @identity).publish
          end

          def notify
            depositor.send_message(@identity.user, message_body, message_subject)
          end

          def message_body
            params = {
              depositor_profile: orcid_profile_uri(depositor.orcid_identity.orcid_id),
              depositor_description: depositor_description,
              profile_path: hyrax_routes.dashboard_profile_path(@identity.user),
              work_title: @work.title.first,
              work_path: routes.send("hyrax_#{@work.class.name.underscore}_path", @work.id),
              approval_path: hyku_addons_routes.orcid_works_approval_path(work_id: @work.id, orcid_id: @identity.orcid_id)
            }
            I18n.t("orcid_identity.notify.notification.body", params)
          end

          def message_subject
            I18n.t("orcid_identity.notify.notification.subject", depositor_description: depositor_description)
          end

          def depositor_description
            "#{depositor.orcid_identity.name} (#{depositor.orcid_identity.orcid_id})"
          end

          def depositor
            @_depositor ||= ::User.find_by_user_key @work.depositor
          end
      end
    end
  end
end
