# frozen_string_literal: true

FactoryBot.define do
  factory :orcid_identity do
    name { "John Smith" }
    orcid_id { "0000-0003-0652-4625" }
    access_token { SecureRandom.uuid }
    token_type { "bearer" }
    refresh_token { SecureRandom.uuid }
    expires_in { 5.years.from_now.to_i.to_s }
    scope { "/read-limited /activities/update" }
    profile_sync_preference { {} }
  end
end
