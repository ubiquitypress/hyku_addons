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
            if %w[Organizational Organisational].include?(creator["creator_name_type"])
            else
              user = User.find_by(email: creator["creator_institutional_email"])
              creator["display_creator_profile"] = user.present? && user.display_profile
            end
            creator
          end
          env.attributes[:creator] = [creators.to_json]
        end
    end
  end
end
