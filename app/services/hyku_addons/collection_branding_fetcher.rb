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

      format_url(fetch_collection_branding(role)&.first)
    end

    def alt_text_for(role)
      fetch_collection_branding(role)&.first&.alt_text
    end

    def target_url_for(role)
      fetch_collection_branding(role)&.first&.target_url
    end

    def get_details_for(role)
      fetch_collection_branding(role).each_with_index.map do |record, index|
        { "target_url": record.target_url, "alt_text": record.alt_text, "url": format_url(record), positions: index }
      end
    end

    private

    # Fetch first banner or logo file information attached to collection if it exists
    def fetch_collection_branding(role)
      return if @cname.nil?

      AccountElevator.switch!(cname)
      CollectionBrandingInfo.where(collection_id: @collection_id.to_s, role: role)
    end

    # Build component for collection json
    def format_url(role)
      return if role.blank?

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
