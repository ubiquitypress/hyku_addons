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
        contact_email: 'abc@abc.com', weekly_email_list: ["aaa@aaa.com", "bbb@bl.uk"], monthly_email_list: ["aaa@aaa.com", "bbb@bl.uk"],
        yearly_email_list: ["aaa@aaa.com", "bbb@bl.uk"],
        index_record_to_shared_search: "true", google_scholarly_work_types: ['Article', 'Book', 'ThesisOrDissertation', 'BookChapter'],
        gtm_id: "GTM-123456", enable_doi: "false",
        hide_form_relationship_tab: "true", shared_login: "true",
        email_format: ["@pacificu.edu", "@ubiquitypress.com", "@test.com"],
        work_unwanted_fields: { "book_chapter": "library_of_congress_classification,related_identifier,alternate_identifier,dewey,series_name,
                                fndr_project_ref,funder,project_name,editor,institution,buy_book",
                                "article": "institution", "news_clipping": "institution" },
        metadata_labels: { "institutional_relationship": "Institution", "family_name":
                           "Last Name", "given_name": "First Name", "org_unit": "Department", "version_number":
                          "Version" },
        institutional_relationship_picklist: "false",
        contributor_roles:  ["Advisor", "Partner Organization", "Contributor ", "Editor"],
        creator_roles: ["Faculty", "Staff", "Student", "Other"],
        help_texts: { "subject": "Select word(s)  about your work.", "org_unit": "Enter your department, center, or group at Pacific", "refereed": "", "additional_information": "",
                      "publisher": " ", "volume": " ", "pagination": " ", "isbn": " ", "issn": " ", "duration":
                      "Enter the length of the work (i.e. 15 minutes).", "version": " ", "keyword":
                      "Enter word(s) about your work." },
        html_required: { "contributor": "false" },
        institutional_relationship: "Pacific University,Other",
        allow_signup: "true",
        redirect_on: "true",
        licence_list: [{ name: "CC BY 4.0 Attribution", url: "https://creativecommons.org/licenses/by/4.0/" },
                       { name: "CC BY-NC 4.0 Attribution-NonCommercial", url: "https://creativecommons.org/licenses/by-nc/4.0/" },
                       { name: "CC BY-SA 4.0 Attribution ShareAlike", url: "https://creativecommons.org/licenses/by-sa/4.0/" },
                       { name: "CC BY-ND 4.0 Attribution NoDerivs", url: "https://creativecommons.org/licenses/by-nd/4.0/" },
                       { name: "CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike", url: "https://creativecommons.org/licenses/by-nc-sa/4.0/" },
                       { name: "CC BY-NC-ND 4.0 Attribution NonCommercial-NoDerivs", url: "https://creativecommons.org/licenses/by-nc-nd/4.0/" },
                       { name: "CC Public Domain Mark 1.0", url: "https://creativecommons.org/publicdomain/mark/1.0/" },
                       { name: "CC0 1.0 Universal Public Domain", url: "http://creativecommons.org/publicdomain/zero/1.0/" }]
      }
    end
    data do
      { is_parent: false }
    end
  end
end
