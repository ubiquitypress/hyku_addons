# frozen_string_literal: true

module HykuAddons
  class CollectionBrandingFetcher
    attr_accessor :collection_id, :cname

    def initialize(collection_id, cname)
      @collection_id = collection_id
      @cname = cname
    end

    def banner
      @_collection_banner ||= fetch_collection_branding("banner")
    end

    def logo
      @_collection_logo ||= fetch_collection_branding("logo")
    end

    private

      def fetch_collection_branding(role)
        return if @cname.nil?

        AccountElevator.switch!(cname)
        CollectionBrandingInfo.where(collection_id: @collection_id.to_s, role: role)
      end
  end
end
