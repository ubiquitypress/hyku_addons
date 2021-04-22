# frozen_string_literal: true

FactoryBot.define do
  factory :admin_set do
    sequence(:title) { |n| ["Admin Set Title #{n}"] }
  end
end
