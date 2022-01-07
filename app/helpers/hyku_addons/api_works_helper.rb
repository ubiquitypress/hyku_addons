# frozen_string_literal: true

# Work related API helper methods
module HykuAddons
  module ApiWorksHelper
    def creator_from_json(creator_json)
      creator_hash = JSON.parse(creator_json || "{}")

      return if creator_hash.blank?

      creator_hash.map do |creator|
        if creator["creator_institutional_email"]&.blank?
          creator.delete("creator_institutional_email")
        else
          user = User.find_by(email: creator["creator_institutional_email"])
          creator.delete("creator_institutional_email") unless user.present? && user.display_profile
        end
        creator
      end
    end
  end
end
