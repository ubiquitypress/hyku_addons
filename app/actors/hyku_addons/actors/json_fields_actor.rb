# frozen_string_literal: true
module HykuAddons
  module Actors
    class JSONFieldsActor < Hyrax::Actors::AbstractActor
      include JsonifyFieldsService

      def create(env)
        jsonify_fields(env.attributes, fields(env), curation_class(env))
        next_actor.create(env)
      end

      def update(env)
        jsonify_fields(env.attributes, fields(env), curation_class(env))
        next_actor.update(env)
      end

      private

        def curation_class(env)
          env.curation_concern.class
        end

        def fields(env)
          curation_class(env).json_fields
        end
    end
  end
end
