# frozen_string_literal: true

module HykuAddons
  module Actors
    class NoteFieldActor < Hyrax::Actors::AbstractActor
      attr_accessor :email

      def create(env)
        puts "LOG_CREATE_AT_NoteFieldActor_BEFORE_serialize_note_field #{env.inspect}"
        serialize_note_field(env)
        puts "LOG_CREATE_AT_NoteFieldActor_AFTER_serialize_note_field #{env.inspect}"
        next_actor.create(env)
      end

      def update(env)
        serialize_note_field(env)
        next_actor.update(env)
      end

      private

      def serialize_note_field(env)
        return unless env.curation_concern.respond_to?(:note)

        @email = env.user.email if previous_note(env).present?

        env.attributes[:note] = previous_note(env).push(*next_note(env))
      end

      def next_note(env)
        env.curation_concern&.note || []
      end

      def previous_note(env)
        return [] if env.attributes[:note].blank?

        [{ email: email, timestamp: Time.zone.now.to_s, note: env.attributes[:note] }.to_json]
      end
    end
  end
end
