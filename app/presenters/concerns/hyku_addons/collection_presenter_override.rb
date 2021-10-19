# frozen_string_literal: true
module HykuAddons
  module CollectionPresenterOverride
    extend ActiveSupport::Concern

    # override by calling elevator switch! in shared_search result it raises error Record not found error
    def collection_type
      work_cname = @solr_document.to_h["account_cname_tesim"]
      account_cname = Array.wrap(work_cname).first

      AccountElevator.switch!(account_cname)
      @collection_type ||= Hyrax::CollectionType.find_by_gid!(collection_type_gid)
    end
  end
end
