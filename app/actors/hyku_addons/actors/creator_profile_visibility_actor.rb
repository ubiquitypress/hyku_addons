# frozen_string_literal: true
module HykuAddons
  module Actors
    class CreatorProfileVisibilityActor < Hyrax::Actors::AbstractActor
      def create(env)
        toggle_visibility(env)

        next_actor.create(env)
      end

      def update(env)
        toggle_visibility(env)

        next_actor.update(env)
      end

      protected

        def toggle_visibility(env)
          creators = extract_creators(env)

          return [] if creators.blank?

          creators.map! do |creator|
            if creator["creator_name_type"] == "Personal"
              user = User.find_by(email: creator["creator_institutional_email"])

          byebug
              creator["creator_profile_visibility"] = user&.display_profile_visibility || User::PROFILE_VISIBILITY[:closed]
            end

            creator
          end

          env.attributes[:creator] = [creators.compact.to_json]
        end

        def extract_creators(env)
          JSON.parse(env.curation_concern[:creator]&.first || "{}")
        end
    end
  end
end
