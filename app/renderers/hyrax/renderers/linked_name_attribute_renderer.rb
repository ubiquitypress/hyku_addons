# frozen_string_literal: true
module Hyrax
  module Renderers
    class LinkedNameAttributeRenderer < JsonAttributeRenderer
      private

        def attribute_value_to_html(value)
          if microdata_value_attributes(field).present?
            "<span#{html_attributes(microdata_value_attributes(field))}>#{li_value(value)}</span>" + badges(value)
          else
            li_value(value) + badges(value)
          end
        end

        # Assumed that the value is a WorkPresenter::PersonOrOrganization
        def li_value(value)
          link_to(ERB::Util.h(value.display_name), search_path(value.display_name))
        end

        def badges(value)
          markup = "<span itemprop='#{field}' style='display:inline-flex'>"
          if [:orcid_link, :isni_link, :ror_link, :grid_link, :wikidata_link].any? { |l| value.send(l).present? }
            markup += "<span>&nbsp;(&nbsp;</span>"
            [:orcid_link, :isni_link, :ror_link, :grid_link, :wikidata_link].each do |id_link|
              next if value.send(id_link).blank?
              markup += value.send(id_link)
              # FIXME: don't display space if last link
              markup += "<span>&nbsp;</span>"
            end
            markup += "<span>)</span>"
          end
          markup += "</span>"
          markup.html_safe
        end

        def search_path(value)
          Rails.application.routes.url_helpers.search_catalog_path("f[#{search_field}][]": value, locale: I18n.locale)
        end

        def search_field
          options.fetch(:search_field, field)
        end
    end
  end
end
