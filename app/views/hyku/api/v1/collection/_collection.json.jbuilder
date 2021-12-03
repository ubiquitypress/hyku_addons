# frozen_string_literal: true
# FIXME: many attributes here left nil so specs will pass
# rubocop:disable Metrics/BlockLength
json.cache! [@account, :collections, collection.id, collection.solr_document[:_version_]] do
  json.uuid collection.id
  json.cname @account.search_only? ? collection.try(:solr_document)&.to_h&.dig("account_cname_tesim")&.first : @account.cname
  json.date_created collection.date_created&.first
  json.date_published nil
  json.description collection.description&.first
  json.keywords collection.keyword&.first
  json.language collection.language&.first
  json.license_for_api_tesim collection.license&.first
  json.publisher collection.publisher&.first
  json.related_url collection.related_url&.first
  json.resource_type collection.resource_type&.first
  json.rights_statements_for_api_tesim collection.solr_document.rights_statement&.first
  json.thumbnail_base64_string nil
  json.thumbnail_url collection.solr_document.thumbnail_path
  if Hyrax::PresenterFactory.build_for(ids: [collection.solr_document.thumbnail_id], presenter_class: Hyrax::FileSetPresenter, presenter_args: [current_ability, request]).first&.solr_document&.public?
    components = {
      scheme: Rails.application.routes.default_url_options.fetch(:protocol, 'http'),
      host: @account.cname,
      path: collection.thumbnail_path.split('?')[0],
      query: collection.thumbnail_path.split('?')[1]
    }
    json.thumbnail_url URI::Generic.build(components).to_s
  else
    json.thumbnail_url nil
  end
  json.title collection.title&.first
  json.type "collection"
  json.visibility collection.visibility
  json.volumes nil
  json.total_works @total_works
end
# rubocop:enable Metrics/BlockLength

if local_assigns[:include_works]
  json.works do
    json.partial! 'hyku/api/v1/work/work', collection: @works, as: :work, collection_docs: Array.wrap(@collection_member_search_results)
  end
end
