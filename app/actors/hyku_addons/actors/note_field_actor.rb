# frozen_string_literal: true
module HykuAddons
  module Actors
    class NoteFieldActor < Hyrax::Actors::AbstractActor
      attr_accessor :email

      def create(env)
        serialize_note_field(env) && next_actor.create(env)
      end

      def update(env)
        serialize_note_field(env) && next_actor.update(env)
      end

      private

        def serialize_note_field(env)
          @email = env.user.email unless previous_note(env).empty?

          env.attributes[:note] = previous_note(env).push(*next_note(env))
        end

        def next_note(env)
          env.curation_concern&.note || []
        end

        def previous_note(env)
          return [] unless env.attributes[:note].present?

          Array(
            { email: email, timestamp: Time.zone.now.to_s, note: env.attributes[:note] }.to_json
          )
        end
    end
  end
end
