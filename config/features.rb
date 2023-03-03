# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Flipflop.configure do

        feature :hide_doi_options,
                default: false,
                description: "Hide DOI settings in deposit form for non-admins/managers"

        feature :oai_endpoint,
                default: true,
                description: "Enable OAI-PMH endpoint for harvesting."

        feature :simplified_admin_set_selection,
                default: false,
                description: "The admin set to deposit works is selected from the add work modal and the relationships tab on the deposit form is hidden for depositors."

        feature :show_repository_objects_links,
                default: true,
                description: "Shows collections, importer and exporter links on the sidebar for non admin users"

        feature :import_mode,
                default: false,
                description: "Import mode - Background jobs are run on specially named queues"

        # If this is turned on by default inside the specs, it'll break a lot of them with the on-create callbacks
        feature :task_master,
                default: ENV["PUBSUB_SERVICEACCOUNT_KEY"].present? && !Rails.env.test?,
                description: "Send tenant repository stats to task master?"

        feature :notes_tab_form,
                default: false,
                description: "Enables the Notes tab in the deposit form"

        feature :cache_api,
                default: false,
                description: "Turns on cache for API endpoints. Experimental"

        feature :cross_tenant_shared_search,
                default: true,
                description: "Turns on cross tenant shared search."

        feature :annotation,
                default: false,
                description: "Turns on links to hypothes.is PDF viewer"

        feature :sso,
                default: false,
                description: "Turns on sso authentication"


        feature :gds_reports,
                default: false,
                description: "Add Google Data Studio reports to the dashaboard"
end
# rubocop:enable Metrics/BlockLength
