# frozen_string_literal: true

# Override a the creator/contributor methods which would otherwise
# return JSON to datacite when a DOI is minted.
module Bolognese
  module Writers
    module HyraxWorkWriterBehavior
      def creators
        @_creators ||= get_authors(pluralize_and_process(:creator))
      end

      def contributors
        @_contributors ||= get_authors(pluralize_and_process(:contributor))
      end

      protected

        # Hyrax uses `creators` but hyku addons uses `creator` - probably not updated after v1.0,
        # so because we are getting the value from Bolognese, we need to translate
        # it, then tell the bologneseify_author_json method to remove `creator_`
        # from the json keys, and pass it back to bolognese in order to finalize
        def pluralize_and_process(type)
          # Get the v2.0 pluralized `creators` and extract the hyku_addon json string.
          # The meta value for the type key, could be nil, not set, or an array of hashes
          data = (meta[type.to_s.pluralize] || [{}]).first.dig("name")

          return if data.blank?

          # Ensure we have the singularized `creator` string being used here as we are now processing hyku_addon data
          bologneseify_author_json(type.to_s.singularize, data)
        end
    end
  end
end
