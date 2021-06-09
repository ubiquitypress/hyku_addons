# frozen_string_literal: true
FactoryBot.define do
  factory :ubiquitous_page, class: HykuAddons::Ubiquitous::Page do
    sequence("name") { |n| "page_#{n}" }
    grid_columns_count { 4 }
    path_matcher { "controller: 'search'" }
  end
end
