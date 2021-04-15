# frozen_string_literal: true

FactoryBot.modify do
  factory :base_user do
    trait :with_orcid_identity do
      association(:orcid_identity, factory: :user_orcid_identity)
    end
  end
end

