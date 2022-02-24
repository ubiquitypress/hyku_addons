# frozen_string_literal: true

module HykuAddons
  class CollectionBrandingFetcher
    attr_accessor :collection_id, :cname

    def initialize(collection_id, cname)
      @collection_id = collection_id
      @cname = cname
    end

    def url_for(role)
      return unless ["banner", "logo"].include? role

      format_url(fetch_collection_branding(role))
    end

    private

      # Fetch first banner or logo file information attached to collection if it exists
      def fetch_collection_branding(role)
        return if @cname.nil?

        AccountElevator.switch!(cname)
        CollectionBrandingInfo.where(collection_id: @collection_id.to_s, role: role)&.first
      end

      # Build component for collection json
      def format_url(role)
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
