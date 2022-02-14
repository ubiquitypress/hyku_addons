# frozen_string_literal: true

module HykuAddons
  class CollectionBrandingFetcher
    attr_accessor :collection_id, :cname

    def initialize(collection_id, cname)
      @collection_id = collection_id
      @cname = cname
    end

    def logo_url
      url(fetch_collection_branding("logo"))
    end

    def banner_url
      url(fetch_collection_branding("banner"))
    end

    private

      def fetch_collection_branding(role)
        return if @cname.nil?

        AccountElevator.switch!(cname)
        CollectionBrandingInfo.where(collection_id: @collection_id.to_s, role: role).first
      end

      def url(role)
        return unless role.present?

        URI::Generic.build(component(role)).to_s
      end

      def component(role)
        {
          scheme: Rails.application.routes.default_url_options.fetch(:protocol, "http"),
          host: @cname,
          path: "/" + role.local_path.split("/")[-4..-1].join("/"),
          alt_text: role.alt_text
        }
      end
  end
end
