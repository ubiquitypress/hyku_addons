# frozen_string_literal: true
module HykuAddons
  module Actors
    class CreatorInstitutionalEmailActor < Hyrax::Actors::AbstractActor
      def create(env)
        check_creator_institutional_email(env) && next_actor.create(env)
      end

      def update(env)
        check_creator_institutional_email(env) && next_actor.update(env)
      end

      private

      def check_creator_institutional_email(env)
        creator_hash = JSON.parse(env.attributes[:creator].try(:first) || "{}")

        return [] if creator_hash.blank?

        creator_hash.map do |creator|
          user = User.find_by(email: creator["creator_institutional_email"])
          if user.present? && user.display_profile
            creator["display_creator_profile?"] = true
          else
            creator["display_creator_profile?"] = false
          end
        end
        env.attributes[:creator] = [Array.wrap(creator_hash).to_json]
      end

    end
  end
end
