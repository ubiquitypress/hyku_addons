# frozen_string_literal: true

# Work related API helper methods
module HykuAddons
  module ApiWorksHelper
    def creator_from_json(creator_json)
      creator_hash = JSON.parse(creator_json || "{}")

      return [] if creator_hash.blank?

      key = "creator_institutional_email"

      creator_hash.map do |creator|
        # Use unless to avoid querying the database for each user
        next unless creator[key].blank? || !display_user_profile?(creator[key])
        creator.delete(key)
      end
      creator_hash
    end

    def display_user_profile?(email)
      user = User.find_by(email: email)
      user.present? && user.display_profile
    end
  end
end
