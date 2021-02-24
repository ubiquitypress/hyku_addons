# frozen_string_literal: true
Flipflop.configure do
  feature :oai_endpoint,
          default: true,
          description: "Enable OAI-PMH endpoint for harvesting."

  feature :doi,
          default: true,
          description: "Toggle the DOI minting for this tenant"
end
