# frozen_string_literal: true
# FIXME: many attributes here left nil so specs will pass
json.cache! [@account, :works, work.id, work.solr_document[:_version_], work.member_of_collection_ids & collection_docs.pluck('id')] do
  json.uuid work.id

  json.abstract work.try(:solr_document)&.dig('abstract_tesim')&.first
  json.adapted_from work.try(:solr_document)&.dig('adapted_from_tesim')
  json.additional_info work.try(:solr_document)&.dig('add_info_tesim')
  json.additional_links work.try(:solr_document)&.dig('additional_links_tesim')
  json.admin_set_name work.admin_set.first
  json.advisor work.try(:solr_document)&.dig('advisor_tesim')
  json.alternative_journal_title work.try(:solr_document)&.dig('alternative_journal_title_tesim')
  json.alternative_book_title work.try(:solr_document)&.dig('alt_book_title_tesim')
  json.alternative_title work.try(:solr_document)&.dig('alt_title_tesim')
  #                                         "article_number" => nil,
  json.audience work.try(:solr_document)&.dig('audience_tesim')
  json.book_title work.try(:solr_document)&.dig('book_title_tesim')
  json.buy_book work.try(:solr_document)&.dig('buy_book_tesim')
  json.challenged work.try(:solr_document)&.dig('challenged_tesim')
  json.citation work.try(:solr_document)&.dig('citation_tesim')
  json.cname @account.cname
  json.committee_member work.try(:solr_document)&.dig('committee_member_tesim')

  creator = work.creator.try(:first)
  json.creator creator.present? ? JSON.parse(creator) : []

  contributor = work.contributor.try(:first)
  json.contributor contributor.present? ? JSON.parse(contributor) : []

  json.date_accepted work.try(:solr_document)&.dig('date_accepted_tesim')
  json.date_published work.try(:solr_document)&.dig('date_published_tesim')
  json.date_published_text work.try(:solr_document)&.dig('date_published_text_tesim')
  json.date_submitted work.date_uploaded
  json.degree work.try(:solr_document)&.dig('degree_tesim')
  json.dewey work.try(:solr_document)&.dig('dewey_tesim')
  json.doi work.try(:solr_document)&.dig('doi_tesim')
  json.duration work.try(:solr_document)&.dig('duration_tesim')
  json.edition work.try(:solr_document)&.dig('edition_tesim')
  json.eissn work.try(:solr_document)&.dig('eissn_tesim')
  json.event_date work.try(:solr_document)&.dig('event_date_tesim')
  json.event_location work.try(:solr_document)&.dig('event_location_tesim')
  json.extent work.try(:solr_document)&.dig('extent_tesim')
  json.event_title work.try(:solr_document)&.dig('event_title_tesim')
  json.files do
    json.has_private_files work.file_set_presenters.any? { |fsp| fsp.solr_document.private? }
    json.has_registered_files work.file_set_presenters.any? { |fsp| fsp.solr_document.registered? }
    json.has_public_files work.file_set_presenters.any? { |fsp| fsp.solr_document.public? }
  end
  json.funder work.try(:solr_document)&.dig('funder_tesim')
  json.funding_description work.try(:solr_document)&.dig('funding_description_tesim')
  json.georeferenced work.try(:solr_document)&.dig('georeferenced_tesim')
  json.institution work.try(:solr_document)&.dig('institution_tesim')
  json.irb_number work.try(:solr_document)&.dig('irb_number_tesim')
  json.irb_status work.try(:solr_document)&.dig('irb_status_tesim')
  json.is_included_in work.try(:solr_document)&.dig('is_included_in_tesim')
  json.isbn work.try(:solr_document)&.dig('isbn_tesim')
  json.issn work.try(:solr_document)&.dig('issn_tesim')
  json.issue work.try(:solr_document)&.dig('issue_tesim')
  json.is_format_of work.try(:solr_document)&.dig('is_format_of_tesim')
  json.part_of work.try(:solr_document)&.dig('part_of_tesim')
  json.journal_title work.try(:solr_document)&.dig('journal_title_tesim')
  json.journal_frequency work.try(:solr_document)&.dig('journal_frequency_tesim')
  json.keywords work.keyword

  if work.try(:solr_document)&.dig('language_tesim').present?
    language_service = HykuAddons::LanguageService.new
    languages = work.language.map do |id|
      language_service.label(id)
    rescue
      nil
    end
    json.language languages.compact
  end

  json.library_of_congress_classification work.try(:solr_document)&.dig('library_of_congress_classification_tesim')

  license = work.try(:solr_document)&.dig('license_tesim')
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

  json.location work.try(:solr_document)&.dig('location_tesim')
  json.latitude work.try(:solr_document)&.dig('latitude_tesim')
  json.longitude work.try(:solr_document)&.dig('longitude_tesim')
  json.medium work.try(:solr_document)&.dig('medium_tesim')
  json.mesh work.try(:solr_document)&.dig('mesh_tesim')
  json.official_url work.try(:solr_document)&.dig('official_url_tesim')
  json.official_link work.try(:solr_document)&.dig('official_link_tesim')
  json.org_unit work.try(:solr_document)&.dig('org_unit_tesim')
  json.outcome work.try(:solr_document)&.dig('outcome_tesim')
  json.page_display_order_number work.try(:solr_document)&.dig('page_display_order_number_tesim')
  json.pagination work.try(:solr_document)&.dig('pagination_tesim')
  json.participant work.try(:solr_document)&.dig('participant_tesim')
  json.photo_caption work.try(:solr_document)&.dig('photo_caption_tesim')
  json.photo_description work.try(:solr_document)&.dig('photo_description_tesim')
  json.place_of_publication work.try(:solr_document)&.dig('place_of_publication_tesim')
  json.prerequisites work.try(:solr_document)&.dig('prerequisites_tesim')
  json.publisher work.publisher
  json.qualification_grantor work.try(:solr_document)&.dig('qualification_grantor_tesim')
  json.qualification_level work.try(:solr_document)&.dig('qualification_level_tesim')

  qualification_name_service = HykuAddons::QualificationNameService.new
  id = work.try(:qualification_name)&.first
  json.qualification_name qualification_name_service.label(id) if id.present?

  json.qualification_subject_text work.try(:solr_document)&.dig('qualification_subject_text_tesim')
  json.reading_level work.try(:solr_document)&.dig('reading_level_tesim')
  json.references work.try(:solr_document)&.dig('references_tesim')
  json.refereed work.try(:solr_document)&.dig('refereed_tesim')
  json.related_exhibition work.try(:solr_document)&.dig('related_exhibition_tesim')
  json.related_exhibition_date work.try(:solr_document)&.dig('related_exhibition_date_tesim')
  json.related_exhibition_venue work.try(:solr_document)&.dig('related_exhibition_venue_tesim')

  related_identifier = work.try(:solr_document)&.dig('related_identifier_tesim')&.first
  if related_identifier.present?
    related_identifier_array = begin
                                 JSON.parse(related_identifier)
                               rescue
                                 nil
                               end
    if related_identifier_array.present?
      json.related_identifier do
        json.array! related_identifier_array do |hash|
          json.name hash['related_identifier']
          json.type hash['related_identifier_type']
          json.relationship hash['relation_type']
        end
      end
    end
  end

  json.related_material work.try(:solr_document)&.dig('related_material_tesim')
  json.related_url work.related_url
  json.time work.try(:solr_document)&.dig('time_tesim')
  json.resource_type work.resource_type
  json.rights_holder work.try(:solr_document)&.dig('rights_holder_tesim')
  json.rights_statement work.rights_statement
  json.rights_statement_text work.try(:solr_document)&.dig('rights_statement_text_tesim')
  json.series_name work.try(:solr_document)&.dig('series_name_tesim')
  json.source work.source
  json.subject work.try(:solr_document)&.dig('subject_tesim')
  json.subject_text work.try(:solr_document)&.dig('subject_text_tesim')
  json.suggested_reviewers work.try(:solr_document)&.dig('suggested_reviewers_tesim')
  json.suggested_student_reviewers work.try(:solr_document)&.dig('suggested_student_reviewers_tesim')

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

  json.table_of_contents work.try(:solr_document)&.dig('table_of_contents_tesim')
  json.title work.title.first
  json.type "work"
  json.version work.try(:solr_document)&.dig('version_number_tesim')
  json.visibility work.solr_document.visibility
  json.volume work.try(:solr_document)&.dig('volume_tesim')
  json.work_type work.model.model_name.to_s
  json.workflow_status work.solr_document.workflow_state

  collection_presenters = work.member_of_collection_presenters.reject { |coll| coll.is_a? Hyrax::AdminSetPresenter }
  collections = collection_presenters.map { |collection| { uuid: collection.id, title: collection.title.first } }
  json.collections collections
end
