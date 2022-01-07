# frozen_string_literal: true

# Work related API helper methods
module HykuAddons
  module ApiWorksHelper
    def creator_from_json(creator_json)
      creator_hash = JSON.parse(creator_json || "{}")

      return if creator_hash.blank?

      key = "creator_institutional_email"

      creator_hash.map do |creator|
        if creator[key] && creator[key].blank?
          creator.delete(key)
        else
          user = User.find_by(email: creator[key])
          creator.delete(key) unless user.present? && user.display_profile
        end

        creator
      end
    end
  end
end
