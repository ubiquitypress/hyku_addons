# frozen_string_literal: true
Flipflop.configure do
  feature :oai_endpoint,
          default: true,
          description: "Enable OAI-PMH endpoint for harvesting."

  feature :simplified_admin_set_selection,
          default: false,
          description: "The admin set to deposit works is selected from the add work modal and the relationships tab on the deposit form is hidden for depositors."

  feature :show_repository_objects_links,
          default: true,
          description: "Shows collections, importer and exporter links on the sidebar for non admin users"

  feature :simplified_deposit_form,
          default: false,
          description: "Hide the DOI tab from non-admin users"

  feature :import_mode,
          default: false,
          description: "Import mode - Background jobs are run on specially named queues"

  feature :cache_enabled,
          default: false,
          description: "TURBO MODE. Turns on cache for API endpoints. Experimental"
  
  feature :task_master,
          default: ENV["PUBSUB_SERVICEACCOUNT_KEY"].present?,
          description: "Send tenant repository stats to task master?"
end
