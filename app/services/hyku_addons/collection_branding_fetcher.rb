# frozen_string_literal: true

module HykuAddons
  class CollectionBrandingFetcher
    def self.collection_banner(id)
      @_collection_banner ||= collection_branding_info(id).where(role: 'banner')
    end

    private_class_method

    def self.collection_branding_info(id)
      @_collection_branding_info ||= CollectionBrandingInfo.where(collection_id: id.to_s)
    end
  end
end
