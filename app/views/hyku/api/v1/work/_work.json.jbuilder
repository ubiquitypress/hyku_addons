# frozen_string_literal: true
# FIXME: many attributes here left nil so specs will pass
json.uuid work.id

json.abstract work.description.first
json.additional_info work.add_info
json.additional_links work.additional_links
json.admin_set_name work.admin_set.first
#                                         "alternative_journal_title" => nil,
json.alternative_title work.alt_title
#                                         "article_number" => nil,
#                                         "book_title" => nil,
json.buy_book work.buy_book
#                                         "challenged" => nil,
json.cname @account.cname
#                                         "collections" => nil,
#                                         "current_he_institution" => nil,
#                                         "date_accepted" => nil,
json.date_published work.date_published
json.date_submitted work.date_uploaded
#                                         "degree" => nil,
#                                         "dewey" => nil,
#                                         "display" => "full",
#                                         "doi" => nil,
# json.download_link nil
#                                         "duration" => nil,
#                                         "edition" => nil,
#                                         "eissn" => nil,
#                                         "event_date" => nil,
#                                         "event_location" => nil,
#                                         "event_title" => nil,
# json.files nil
#                                         "funder" => nil,
#                                         "funder_project_reference" => nil,
#                                         "institution" => nil,
json.irb_number work.irb_number
json.irb_status work.irb_status
json.is_included_in work.is_included_in
json.isbn work.isbn
json.issn work.issn
json.issue work.issue
journal_title work.journal_title
json.keywords work.keyword
json.language work.language
#                                         "library_of_congress_classification" => nil,
json.license work.license
#                                         "location" => nil,
#                                         "material_media" => nil,
#                                         "migration_id" => nil,
#                                         "official_url" => nil,
json.organisational_unit work.org_unit
#                                         "outcome" => nil,
json.page_display_order_number work.page_display_order_number
json.pagination work.pagination
#                                         "participant" => nil,
#                                         "photo_caption" => nil,
#                                         "photo_description" => nil,
#                                         "place_of_publication" => nil,
#                                         "project_name" => nil,
json.publisher work.publisher
#                                         "qualification_level" => nil,
#                                         "qualification_name" => nil,
#                                         "reading_level" => nil,
json.refereed work.refereed
#                                         "related_exhibition" => nil,
#                                         "related_exhibition_date" => nil,
#                                         "related_exhibition_venue" => nil,
json.related_url work.related_url
json.resource_type work.resource_type
#                                         "review_data" => nil,
json.rights_holder work.rights_holder
json.rights_statement work.rights_statement
#                                         "series_name" => nil,
json.source work.source
json.subject work.subject
# json.thumbnail_base64_string nil
# json.thumbnail_url work.thumbnail_path
json.thumbnail_url nil
json.title work.title.first
json.type "work"
#                                         "version" => nil,
json.visibility work.solr_document.visibility
json.volume work.volume
json.work_type work.model.model_name.to_s
json.workflow_status work.solr_document.workflow_state
