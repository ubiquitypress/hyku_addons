# frozen_string_literal: true

FactoryBot.define do
  factory :orcid_identity do
    name { "John Smith" }
    # Create a random orcid_id, 4 groups of 4, 4 digit numbers, hyphen seperated, i.e. "6245-1498-7128-1812"
    orcid_id { SecureRandom.random_number(10**16).to_s.scan(/.{1,4}/).join("-") }
    access_token { SecureRandom.uuid }
    token_type { "bearer" }
    refresh_token { SecureRandom.uuid }
    expires_in { 5.years.from_now.to_i.to_s }
    scope { "/read-limited /activities/update" }
    profile_sync_preference { {} }
  end
end
