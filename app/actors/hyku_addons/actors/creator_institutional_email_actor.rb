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
          creator_hash = JSON.parse(env.attributes[:creator]&.first || "{}")

          return [] if creator_hash.blank?

          creators = creator_hash.map do |creator|
            if creator["creator_name_type"] == "Personal"
              creator["creator_profile_visibility"] = "closed"
              user = User.find_by(email: creator["creator_institutional_email"])

              creator["creator_profile_visibility"] = user.display_profile_visibility if user.present?
            end

            creator
          end

          env.attributes[:creator] = [creators.compact.to_json]
        end
    end
  end
end
