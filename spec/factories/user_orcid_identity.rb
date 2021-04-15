# frozen_string_literal: true

FactoryBot.define do
  factory :user_orcid_identity do
    access_token { SecureRandom.uuid }
    token_type { "bearer" }
    refresh_token { SecureRandom.uuid }
    expires_in { "631138518" }
    scope { "/read-limited /activities/update" }
    orcid_id { "0000-0003-0652-4625" }
  end
end
