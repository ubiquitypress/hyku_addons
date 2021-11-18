# frozen_string_literal: true
FactoryBot.define do
  factory :fully_described_work, parent: :work do
    volume { ["1"] }
    pagination { "1" }
    issn { "" }
    eissn { "" }
    official_link { "" }
    series_name { [""] }
    edition { "" }
    event_title { [""] }
    event_date { ["2009"] }
    event_location { [""] }
    book_title { "" }
    journal_title { "" }
    issue { "" }
    article_num { "" }
    isbn { "" }
    media { [""] }
    related_exhibition { [""] }
    related_exhibition_date { ["2009"] }
    version { [""] }
    version_number { [""] }
    alternative_journal_title { [""] }
    related_exhibition_venue { [""] }
    current_he_institution { [""] }
    qualification_name { "" }
    qualification_level { "" }
    duration { [""] }
    editor { [""] }

    institution { [""] }
    org_unit { [""] }
    refereed { "" }
    funder { [""] }
    fndr_project_ref { [""] }
    add_info { "" }
    date_published { "" }
    date_accepted { "" }
    date_submitted { "" }
    project_name { [""] }
    rights_holder { [""] }
    place_of_publication { [""] }
    abstract { "" }
    alternate_identifier { [""] }
    related_identifier { [""] }
    library_of_congress_classification { [""] }
    alt_title { [""] }
    dewey { "" }

    creator { [""] }
    contributor { [""] }
  end

  factory :task_master_work, parent: :work do
    sequence(:title) { |n| ["Test Title #{n}"] }

    transient do
      user { create(:user) }
      with_admin_set { false }
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    trait :with_one_file do
      before(:create) do |work, evaluator|
        work.ordered_members << create(:file_set, user: evaluator.user, title: ["A Contained PDF FileSet"], label: "filename.pdf")
      end
    end
  end
end
