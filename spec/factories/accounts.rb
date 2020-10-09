# frozen_string_literal: true
FactoryBot.define do
  factory :datacite_endpoint do
    options { Hash.new(mode: 'test', prefix: '10.1234', username: 'user123', password: 'pass123') }
  end
end

FactoryBot.modify do
  factory :account do
    sequence(:cname) { |_n| srand }
    solr_endpoint
    redis_endpoint
    fcrepo_endpoint
    datacite_endpoint
    settings do
      {
        contact_email: 'abc@abc.com', weekly_email_list: ["aaa@aaa.com; bbb@bl.uk"], monthly_email_list: ["aaa@aaa.com; bbb@bl.uk"],
        yearly_email_list: ["aaa@aaa.com; bbb@bl.uk"],
        index_record_to_shared_search: true, google_scholarly_work_types: ['Article', 'Book', 'ThesisOrDissertation', 'BookChapter']
      }
    end
    data do
      { is_parent: false }
    end
  end
end
