
# frozen_string_literal: true
# Override to explicitly call our license service with model
module Hyrax::Renderers::LicenseAttributeRendererBehavior
  def attribute_value_to_html(value)
    begin
      parsed_uri = URI.parse(value)
    rescue URI::InvalidURIError
      nil
    end

    license_service = HykuAddons::LicenseService.new(model: options[:work_type]&.safe_constantize)
    has_term = license_service.active_elements.pluck("id").include?(value)

    if parsed_uri.nil? || !has_term
      ERB::Util.h(value)
    else
      %(<a href=#{ERB::Util.h(value)} target="_blank">#{license_service.label(value)}</a>)
    end
  end
end
