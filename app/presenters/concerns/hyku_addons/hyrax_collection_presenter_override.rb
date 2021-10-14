module HykuAddons
  module HyraxCollectionPresenterOverride
    extend ActiveSupport::Concern

    def collection_type
      AccountElevator.switch!(@solr_document.to_h['work_tenant_cname_tesim')
     @collection_type ||= Hyrax::CollectionType.find_by_gid!(collection_type_gid)
   end
  end
end
