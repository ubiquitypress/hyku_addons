# frozen_string_literal: true
# FIXME: many attributes here left nil so specs will pass
json.cache! [@account, :works, work.id, work.solr_document[:_version_], work.member_of_collection_ids & collection_docs.pluck('id')] do
  json.uuid work.id

  json.abstract work.try(:solr_document)&.to_h&.dig('abstract_tesim')&.first
  json.adapted_from work.try(:solr_document)&.to_h&.dig('adapted_from_tesim')
  json.additional_info work.try(:solr_document)&.to_h&.dig('add_info_tesim')
  json.additional_links work.try(:solr_document)&.to_h&.dig('additional_links_tesim')
  json.admin_set_name work.admin_set.first
  json.advisor work.try(:solr_document)&.to_h&.dig('advisor_tesim')
  json.alternative_journal_title work.try(:solr_document)&.to_h&.dig('alternative_journal_title_tesim')
  json.alternative_book_title work.try(:solr_document)&.to_h&.dig('alt_book_title_tesim')
  json.alternative_title work.try(:solr_document)&.to_h&.dig('alt_title_tesim')
  json.article_number work.try(:solr_document)&.to_h&.dig('article_num_tesim')
  json.audience work.try(:solr_document)&.to_h&.dig('audience_tesim')
  json.book_title work.try(:solr_document)&.to_h&.dig('book_title_tesim')
  json.buy_book work.try(:solr_document)&.to_h&.dig('buy_book_tesim')
  json.challenged work.try(:solr_document)&.to_h&.dig('challenged_tesim')
  json.citation work.try(:solr_document)&.to_h&.dig('citation_tesim')
  json.cname @account.search_only? ? work.try(:solr_document)&.to_h&.dig("account_cname_tesim")&.first : @account.cname
  json.committee_member work.try(:solr_document)&.to_h&.dig('committee_member_tesim')

  creator_hash = work.creator.try(:first)
  creator_json = JSON.parse(creator_hash) if creator_hash.present?
  if creator_json.present?
    creator_json.each_with_index do |creator, index|
      if creator["creator_institutional_email"].blank?
        creator_json[index] = creator_json[index].except!("creator_institutional_email")
        next
      else
        user = User.find_by(email: creator["creator_institutional_email"])
        creator_json[index] = creator_json[index].except!("creator_institutional_email") unless user.present? && user.display_profile # Removes field if the user is not public/not found
      end
    end
  end
  json.creator creator_hash.present? ? creator_json : []

  contributor = work.contributor.try(:first)
  json.contributor contributor.present? ? JSON.parse(contributor) : []

  json.date_accepted work.try(:solr_document)&.to_h&.dig('date_accepted_tesim')
  json.date_published work.try(:solr_document)&.to_h&.dig('date_published_tesim')
  json.date_published_text work.try(:solr_document)&.to_h&.dig('date_published_text_tesim')
  json.date_submitted work.date_uploaded
  json.degree work.try(:solr_document)&.to_h&.dig('degree_tesim')
  json.dewey work.try(:solr_document)&.to_h&.dig('dewey_tesim')

  doi = work.try(:solr_document)&.to_h&.dig('doi_ssi')
  json.doi doi.present? ? "https://doi.org/#{doi}" : nil

  json.duration work.try(:solr_document)&.to_h&.dig('duration_tesim')
  json.edition work.try(:solr_document)&.to_h&.dig('edition_tesim')
  json.eissn work.try(:solr_document)&.to_h&.dig('eissn_tesim')
  json.event_date work.try(:solr_document)&.to_h&.dig('event_date_tesim')
  json.event_location work.try(:solr_document)&.to_h&.dig('event_location_tesim')
  json.extent work.try(:solr_document)&.to_h&.dig('extent_tesim')
  json.event_title work.try(:solr_document)&.to_h&.dig('event_title_tesim')

  json.files do
    json.has_private_files work.file_set_presenters.any? { |fsp| fsp.solr_document.private? }
    json.has_registered_files work.file_set_presenters.any? { |fsp| fsp.solr_document.registered? }
    json.has_public_files work.file_set_presenters.any? { |fsp| fsp.solr_document.public? }
  end

  funder = work.try(:solr_document)&.to_h&.dig('funder_tesim').try(:first)
  json.funder funder.present? ? JSON.parse(funder) : []

  json.funder_project_ref work.try(:solr_document)&.to_h&.dig('fndr_project_ref_tesim')
  json.funding_description work.try(:solr_document)&.to_h&.dig('funding_description_tesim')
  json.georeferenced work.try(:solr_document)&.to_h&.dig('georeferenced_tesim')
  json.institution work.try(:solr_document)&.to_h&.dig('institution_tesim')
  json.irb_number work.try(:solr_document)&.to_h&.dig('irb_number_tesim')
  json.irb_status work.try(:solr_document)&.to_h&.dig('irb_status_tesim')
  json.is_included_in work.try(:solr_document)&.to_h&.dig('is_included_in_tesim')
  json.isbn work.try(:solr_document)&.to_h&.dig('isbn_tesim')
  json.issn work.try(:solr_document)&.to_h&.dig('issn_tesim')
  json.issue work.try(:solr_document)&.to_h&.dig('issue_tesim')
  json.is_format_of work.try(:solr_document)&.to_h&.dig('is_format_of_tesim')
  json.part_of work.try(:solr_document)&.to_h&.dig('part_of_tesim')
  json.journal_title work.try(:solr_document)&.to_h&.dig('journal_title_tesim')
  json.journal_frequency work.try(:solr_document)&.to_h&.dig('journal_frequency_tesim')
  json.keywords work.keyword

  if work.try(:solr_document)&.to_h&.dig('language_tesim').present?
    language_service = HykuAddons::LanguageService.new
    languages = work.language.map do |id|
      language_service.label(id)
    rescue
      nil
    end
    json.language languages.compact
  end

  json.library_of_congress_classification work.try(:solr_document)&.to_h&.dig('library_of_congress_classification_tesim')

  license = work.try(:solr_document)&.to_h&.dig('license_tesim')
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

  json.location work.try(:solr_document)&.to_h&.dig('location_tesim')
  json.latitude work.try(:solr_document)&.to_h&.dig('latitude_tesim')
  json.longitude work.try(:solr_document)&.to_h&.dig('longitude_tesim')
  json.medium work.try(:solr_document)&.to_h&.dig('medium_tesim')
  json.mentor work.try(:solr_document)&.to_h&.dig('mentor_tesim')
  json.mesh work.try(:solr_document)&.to_h&.dig('mesh_tesim')
  json.official_url work.try(:solr_document)&.to_h&.dig('official_url_tesim')
  json.official_link work.try(:solr_document)&.to_h&.dig('official_link_tesim')
  json.org_unit work.try(:solr_document)&.to_h&.dig('org_unit_tesim')
  json.outcome work.try(:solr_document)&.to_h&.dig('outcome_tesim')
  json.page_display_order_number work.try(:solr_document)&.to_h&.dig('page_display_order_number_tesim')
  json.pagination work.try(:solr_document)&.to_h&.dig('pagination_tesim')
  json.participant work.try(:solr_document)&.to_h&.dig('participant_tesim')
  json.photo_caption work.try(:solr_document)&.to_h&.dig('photo_caption_tesim')
  json.photo_description work.try(:solr_document)&.to_h&.dig('photo_description_tesim')
  json.place_of_publication work.try(:solr_document)&.to_h&.dig('place_of_publication_tesim')
  json.prerequisites work.try(:solr_document)&.to_h&.dig('prerequisites_tesim')
  json.project_name work.try(:solr_document)&.to_h&.dig('project_name_tesim')
  json.publisher work.publisher
  json.qualification_grantor work.try(:solr_document)&.to_h&.dig('qualification_grantor_tesim')
  json.qualification_level work.try(:solr_document)&.to_h&.dig('qualification_level_tesim')

  qualification_name_service = HykuAddons::QualificationNameService.new
  id = work.try(:qualification_name)&.first
  json.qualification_name qualification_name_service.label(id) if id.present?

  json.qualification_subject_text work.try(:solr_document)&.to_h&.dig('qualification_subject_text_tesim')
  json.reading_level work.try(:solr_document)&.to_h&.dig('reading_level_tesim')
  json.references work.try(:solr_document)&.to_h&.dig('references_tesim')
  json.refereed work.try(:solr_document)&.to_h&.dig('refereed_tesim')
  json.related_exhibition work.try(:solr_document)&.to_h&.dig('related_exhibition_tesim')
  json.related_exhibition_date work.try(:solr_document)&.to_h&.dig('related_exhibition_date_tesim')
  json.related_exhibition_venue work.try(:solr_document)&.to_h&.dig('related_exhibition_venue_tesim')

  related_identifier = work.try(:solr_document)&.to_h&.dig('related_identifier_tesim')&.first
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

  json.related_material work.try(:solr_document)&.to_h&.dig('related_material_tesim')
  json.related_url work.try(:solr_document)&.to_h&.dig('related_url_tesim')
  json.time work.try(:solr_document)&.to_h&.dig('time_tesim')
  json.resource_type work.resource_type
  json.rights_holder work.try(:solr_document)&.to_h&.dig('rights_holder_tesim')
  json.rights_statement work.rights_statement
  json.rights_statement_text work.try(:solr_document)&.to_h&.dig('rights_statement_text_tesim')
  json.series_name work.try(:solr_document)&.to_h&.dig('series_name_tesim')
  json.source work.source
  json.subject work.try(:solr_document)&.to_h&.dig('subject_tesim')
  json.subject_text work.try(:solr_document)&.to_h&.dig('subject_text_tesim')
  json.suggested_reviewers work.try(:solr_document)&.to_h&.dig('suggested_reviewers_tesim')
  json.suggested_student_reviewers work.try(:solr_document)&.to_h&.dig('suggested_student_reviewers_tesim')

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
  json.version work.try(:solr_document)&.to_h&.dig('version_number_tesim')
  json.visibility work.solr_document.visibility
  json.volume work.try(:solr_document)&.to_h&.dig('volume_tesim')
  json.work_type work.model.model_name.to_s
  json.workflow_status work.solr_document.workflow_state

  collection_presenters = work.member_of_collection_presenters.reject { |coll| coll.is_a? Hyrax::AdminSetPresenter }
  collections = collection_presenters.map { |collection| { uuid: collection.id, title: collection.title.first } }
  json.collections collections
end
