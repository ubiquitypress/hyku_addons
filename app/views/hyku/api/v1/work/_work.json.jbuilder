# frozen_string_literal: true
# FIXME: many attributes here left nil so specs will pass
json.uuid work.id

json.abstract work.try(:abstract)
json.adapted_from work.try(:adapted_from)
json.additional_info work.try(:add_info)
json.additional_links work.try(:additional_links)
json.admin_set_name work.admin_set.first
#                                         "alternative_journal_title" => nil,
json.alternative_book_title work.try(:alt_book_title)
json.alternative_title work.try(:alt_title)
#                                         "article_number" => nil,
json.audience work.try(:audience)
json.book_title work.try(:book_title)
json.buy_book work.try(:buy_book)
json.challenged work.try(:challenged)
json.cname @account.cname
#                                         "collections" => nil,
creator = work.creator.try(:first)
json.creator creator.present? ? JSON.parse(creator) : []

contributor = work.contributor.try(:first)
json.contributor contributor.present? ? JSON.parse(contributor) : []
#                                         "current_he_institution" => nil,
#                                         "date_accepted" => nil,
json.date_published work.try(:date_published)
json.date_submitted work.date_uploaded
json.degree work.try(:degree)
#                                         "dewey" => nil,
#                                         "display" => "full",
#                                         "doi" => nil,
# json.download_link nil
json.duration work.try(:duration)
json.edition work.try(:edition)
#                                         "eissn" => nil,
#                                         "event_date" => nil,
json.event_location work.try(:event_location)
#                                         "event_title" => nil,
json.files do
  json.has_private_files work.file_set_presenters.any? { |fsp| fsp.solr_document.private? }
  json.has_registered_files work.file_set_presenters.any? { |fsp| fsp.solr_document.registered? }
  json.has_public_files work.file_set_presenters.any? { |fsp| fsp.solr_document.public? }
end
#                                         "funder" => nil,
#                                         "funder_project_reference" => nil,
#                                         "institution" => nil,
json.irb_number work.try(:irb_number)
json.irb_status work.try(:irb_status)
json.is_included_in work.try(:is_included_in)
json.isbn work.try(:isbn)
json.issn work.try(:issn)
json.issue work.try(:issue)
json.journal_title work.try(:journal_title)
json.keywords work.keyword
if work.language.present?
  language_service = HykuAddons::LanguageService.new
  begin
    languages = work.language.map { |id| language_service.label(id) }.compact
  rescue
    nil
  end
  json.language languages
end
#                                         "library_of_congress_classification" => nil,
license = work.try(:license)
license_hash = HykuAddons::LicenseService.new.select_all_options.to_h
if license.present?
  json.license do
    json.array! license do |item|
      if license_hash.values.include?(item)
        json.name license_hash.key(item)
        json.link item
      end
    end
  end
else
  json.license []
end

json.location work.try(:location)
json.latitude work.try(:latitude)
json.longitude work.try(:longitude)
#                                         "material_media" => nil,
#                                         "migration_id" => nil,
#                                         "official_url" => nil,
json.official_link work.try(:official_link)
json.organisational_unit work.try(:org_unit)
json.outcome work.try(:outcome)
json.page_display_order_number work.try(:page_display_order_number)
json.pagination work.try(:pagination)
json.participant work.try(:participant)
json.photo_caption work.try(:photo_caption)
json.photo_description work.try(:photo_description)
json.place_of_publication work.try(:place_of_publication)
#                                         "project_name" => nil,
json.prerequisites work.try(:prerequisites)
json.publisher work.publisher
json.qualification_name work.try(:qualification_level)
#                                         "qualification_name" => nil,
json.reading_level work.try(:reading_level)
json.refereed work.try(:refereed)
#                                         "related_exhibition" => nil,
#                                         "related_exhibition_date" => nil,
#                                         "related_exhibition_venue" => nil,
json.related_identifier work.try(:related_identifier)
json.related_material work.try(:related_material)
json.related_url work.related_url
json.resource_type work.resource_type
#                                         "review_data" => nil,
json.rights_holder work.try(:rights_holder)
json.rights_statement work.rights_statement
json.series_name work.try(:series_name)
json.source work.source
json.subject work.subject
json.suggested_reviewers work.try(:suggested_reviewers)
json.suggested_student_reviewers work.try(:suggested_student_reviewers)
# json.thumbnail_base64_string nil
if work.representative_presenter&.solr_document&.public?
  components = {
    scheme: Rails.application.routes.default_url_options.fetch(:protocol, 'http'),
    host: @account.cname,
    path: work.solr_document.thumbnail_path.split('?')[0],
    query: work.solr_document.thumbnail_path.split('?')[1]
  }
  json.thumbnail_url URI::Generic.build(components).to_s
else
  json.thumbnail_url nil
end
json.table_of_contents work.try(:table_of_contents)
json.title work.title.first
json.type "work"
json.version work.try(:version_number)
json.visibility work.solr_document.visibility
json.volume work.try(:volume)
json.work_type work.model.model_name.to_s
json.workflow_status work.solr_document.workflow_state

collection_presenters = work.member_of_collection_presenters.reject { |coll| coll.is_a? Hyrax::AdminSetPresenter }
collections = collection_presenters.map { |collection| { uuid: collection.id, title: collection.title.first } }
json.collections collections
