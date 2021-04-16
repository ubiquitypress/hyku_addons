# frozen_string_literal: true

FactoryBot.define do
  factory :orcid_identity do
    name { "John Smith" }
    access_token { SecureRandom.uuid }
    token_type { "bearer" }
    refresh_token { SecureRandom.uuid }
    expires_in { 5.years.from_now.to_i.to_s }
    scope { "/read-limited /activities/update" }
    orcid_id { "0000-0003-0652-4625" }
  end
end
