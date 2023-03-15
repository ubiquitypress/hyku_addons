# frozen_string_literal: true
module HykuAddons
  module Actors
    class JSONFieldsActor < Hyrax::Actors::AbstractActor
      def create(env)
        puts "LOG_CREATE_AT_JSONFieldsActor_BEFORE_jsonify_fields #{env.inspect}"
        jsonify_fields(env) && next_actor.create(env)
        puts "LOG_CREATE_AT_JSONFieldsActor_AFTER_jsonify_fields #{env.inspect}"
      end

      def update(env)
        jsonify_fields(env) && next_actor.update(env)
      end

      private

      def jsonify_fields(env)
        puts "LOG_jsonify_fields_AT_JSONFieldsActor_Line_18 #{env.inspect}"
        env.curation_concern.class.json_fields.each do |field|
          # This handles the case when field is a key/value pair coming from the yaml schema
          puts "LOG_jsonify_fields_AT_JSONFieldsActor_Line_21_field #{field.inspect}"
          field = field.first if field.is_a?(Array)

          puts "LOG_jsonify_fields_AT_JSONFieldsActor_Line_24_field #{field.inspect}"
          if name_blank?(field, env.attributes[field]) || recursive_blank?(env.attributes[field])
            env.attributes.delete(field)
          else
            env.attributes[field].reject! { |o| name_blank?(field, o) || recursive_blank?(o) } if env.attributes[field].is_a?(Array)
            env.attributes[field] = env.attributes[field].to_json
          end
          puts "LOG_jsonify_fields_AT_JSONFieldsActor_Line_31_env_attributes_field #{env.attributes[field].inspect}"
          ensure_multiple!(env, field)
          puts "LOG_jsonify_fields_AT_JSONFieldsActor_Line_33_env_attributes_field #{env.attributes[field].inspect}"
        end
      end

      def name_blank?(field, obj)
        return false unless field.in? [:creator, :contributor, :editor]

        recursive_blank?(Array(obj).map { |o| o.reject { |k, _v| k == "#{field}_name_type" } })
      end

      def recursive_blank?(obj)
        case obj
        when Hash
          obj.values.all? { |o| recursive_blank?(o) }
        when Array
          obj.all? { |o| recursive_blank?(o) }
        else
          obj.blank?
        end
      end

      def ensure_multiple!(env, field)
        env.attributes[field] = Array(env.attributes[field]) if env.curation_concern.class.multiple?(field)
      end
    end
  end
end
