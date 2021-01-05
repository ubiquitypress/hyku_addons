# frozen_string_literal: true
module HykuAddons
  module SolrDocumentRis
    extend ActiveSupport::Concern

    included do
      use_extension(HykuAddons::RisContentNegotiation)
    end
  end
end
