# frozen_string_literal: true
#
module HykuAddons
  module HelperBehavior
    include HykuAddons::MultipleMetadataFieldsHelper
    include HykuAddons::CreatorFieldHelper
    include HykuAddons::ContributorFieldHelper
    include HykuAddons::RelatedIdentifierHelper
    include HykuAddons::SimplifiedAdminSetSelectionWorkFormHelper
    include HykuAddons::SimplifiedDepositFormHelper
    include HykuAddons::NotesTabFormHelper
    include Hyrax::Orcid::HelperBehavior

    # Override the Hyrax::Orcid JSON Fields creator/contributor helper, method which uses different participant name keys
    def participant_to_string(type, participants)
      return "-" if participants.blank?

      participants
        .first
        .then { |s| JSON.parse(s) }
        .each_with_object([]) do |hash, array|
          array << hash.slice("#{type}_given_name", "#{type}_family_name").values.join(" ")
        end
        .then { |a| a.compact.reject(&:blank?).join(", ") }
    end
  end
end
