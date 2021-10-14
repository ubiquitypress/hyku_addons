# frozen_string_literal: true

module HykuAddons
  module Bolognese
    module JsonFieldsReader
      extend ActiveSupport::Concern

      # Prepare the json to be parsed through Bolognese get_authors method
      # Bologese wants a hash with `givenName` not `creator_given_name` etc
      #
      # NOTE: The downcase is to counteract Bolognese titleizing the values
      def bologneseify_author_json(type, json)
        obj = JSON.parse(json)
        transformed = Array.wrap(obj).map { |cr| cr.transform_keys { |k| k.downcase.gsub(/#{type}_/, "") }.deep_transform_keys { |k| k.camelize(:lower) } }

        transformed.each do |t|
          next unless t["orcid"].present?

          t["nameIdentifier"] = {
            "nameIdentifierScheme" => "orcid",
            "__content__" => t["orcid"].downcase
          }
        end

        transformed.compact

      rescue JSON::ParserError
        json
      end
    end
  end
end
