# frozen_string_literal: true
FactoryBot.define do
  factory :ubiquitous_content, class: HykuAddons::Ubiquitous::Content do
    sequence("name") { |n| "content_#{n}" }
    content_type { FeaturedWork }
    content_id { '*' }
    limit { 1 }
    order { "created_at ASC" }
    conditions { nil }
  end
end
