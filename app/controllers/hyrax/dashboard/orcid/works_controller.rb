# frozen_string_literal: true

module Hyrax
  module Dashboard
    module Orcid
      class WorksController < ::ApplicationController
        def approve
          # TODO: Put this in a configuration object
          action = "perform_#{Rails.env.development? ? 'now' : 'later'}"
          Hyrax::Orcid::PublishWorkJob.send(action, work, identity)

          flash[:notice] = I18n.t("orcid_identity.notify.approved")
          redirect_back fallback_location: notifications_path
        end

        protected

        def work
          @_work ||= ActiveFedora::Base.find(permitted_params.dig(:work_id))
        end

        def identity
          @_identity = OrcidIdentity.find_by(orcid_id: permitted_params.dig(:orcid_id))
        end

        def permitted_params
          params.permit(:work_id, :orcid_id)
        end
      end
    end
  end
end

