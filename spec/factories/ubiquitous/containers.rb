# frozen_string_literal: true
FactoryBot.define do
  factory :ubiquitous_container, class: HykuAddons::Ubiquitous::Container do
    sequence("name") { |n| "container_#{n}" }
    association :content, factory: :ubiquitous_content
    style { HykuAddons::Ubiquitous::Container.styles.keys.first }
    custom_title { "My custom title" }
    custom_description { "My custom description" }
    # position { 0 }
    # height { 1 }
    # width  { 2 }
  end
end
