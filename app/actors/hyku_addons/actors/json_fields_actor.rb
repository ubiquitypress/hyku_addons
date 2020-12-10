module HykuAddons
  module Actors
    class JSONFieldsActor < Hyrax::Actors::BaseActor
      def create(env)
        jsonify_fields(env) && next_actor.create(env)
      end

      def update(env)
        jsonify_fields(env) && next_actor.update(env)
      end

      private

      def jsonify_fields(env)
        env.curation_concern.class.json_fields.each do |field|
          env.attributes[field] = env.attributes[field].to_json
          env.attributes[field] = Array(env.attributes[field]) if env.curation_concern.class.multiple?(field)
        end
      end
    end
  end
end