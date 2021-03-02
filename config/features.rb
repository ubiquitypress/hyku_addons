# frozen_string_literal: true
Flipflop.configure do
  feature :oai_endpoint,
          default: true,
          description: "Enable OAI-PMH endpoint for harvesting."

  feature :revised_admin_set_layout,
          default: false,
          description: "Move the admin set to the works modal and hide the relationships tab on the deposit form"
end
