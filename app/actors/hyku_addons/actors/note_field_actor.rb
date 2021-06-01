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
          if env.attributes[:note].present?
            @email = env.user.email
            env.attributes[:note] =
              if env.curation_concern.note.present?
                env.curation_concern.note + Array(process_note_hash(env.attributes[:note]).to_json)
              else
                Array(process_note_hash(env.attributes[:note]).to_json)
              end
          else
            env.attributes[:note] = []
          end
        end

        def process_note_hash(note)
          { email: email, timestamp: Time.zone.now.to_s, note: note }
        end
    end
  end
end
