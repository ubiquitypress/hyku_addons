# frozen_string_literal: true

module Hyrax
  module Orcid
    module OrcidHelper
      ORCID_REGEX = %r{
        (?:(http|https):\/\/
        (?:www\.(?:sandbox\.)?)?orcid\.org\/)?
        (\d{4}[[:space:]-]\d{4}[[:space:]-]\d{4}[[:space:]-]\d{3}[0-9X]+)
      }x

      def validate_orcid(orcid)
        orcid = orcid.match(ORCID_REGEX)

        orcid.to_s.gsub(/[[:space:]]/, "-") if orcid.present?
      end
    end
  end
end

