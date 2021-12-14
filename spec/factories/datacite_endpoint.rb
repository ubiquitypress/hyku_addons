# frozen_string_literal: true

FactoryBot.define do
  factory :datacite_endpoint do
    options { Hash.new(mode: :test, prefix: "10.1234", username: "user123", password: "pass123") }
  end
end
