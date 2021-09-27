# frozen_string_literal: true

# Hyrax::Orcid::HelperBehavior is included in Hyrax::Helper
module HykuAddons
  module OrcidHelperBehavior
    extend ActiveSupport::Concern

    # Override the Hyrax::Orcid JSON Fields creator/contributor helper, method which uses different participant name keys
    def participant_to_string(type, participants)
      return "-" if participants.blank?

      participants
        .first
        .then { |s| JSON.parse(s) }
        .each_with_object([]) { |hash, array| array << hash.slice("#{type}_given_name", "#{type}_family_name").values.join(" ") }
        .then { |a| a.compact.reject(&:blank?).join(", ") }
    end
  end
end
