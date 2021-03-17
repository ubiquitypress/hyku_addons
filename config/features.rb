# frozen_string_literal: true
Flipflop.configure do
  feature :oai_endpoint,
          default: true,
          description: "Enable OAI-PMH endpoint for harvesting."

  feature :simplified_admin_set_selection,
          default: false,
          description: "The admin set to deposit works is selected from the add work modal and the relationships tab on the deposit form is hidden for depositors."

  feature :hide_collections_link,
          default: false,
          description: "Hides collections tab on sidebar for non admin users"

  feature :simplified_deposit_form,
          default: false,
          description: "Hide the DOI tab from non-admin users"
end
