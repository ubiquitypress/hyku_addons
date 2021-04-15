# frozen_string_literal: true

module Hyrax
  module UserBehavior
    extend ActiveSupport::Concern

    included do
      has_one :orcid_identity, class_name: "UserOrcidIdentity"
    end

    def orcid_identity_from_authorization(params)
      transformed = params.symbolize_keys.except(:name)
      transformed[:orcid_id] = transformed.delete(:orcid)

      create_orcid_identity(transformed)
    end

    def orcid_identity?
      orcid_identity.present?
    end
  end
end
