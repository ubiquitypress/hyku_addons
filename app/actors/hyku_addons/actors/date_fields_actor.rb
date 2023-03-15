# frozen_string_literal: true
module HykuAddons
  module Actors
    class DateFieldsActor < Hyrax::Actors::AbstractActor
      def create(env)
        puts "LOG_CREATE_AT_DateFieldsActor_BEFORE_serialize_date_fields #{env.inspect}"
        serialize_date_fields(env) && next_actor.create(env)
        puts "LOG_CREATE_AT_DateFieldsActor_AFTER_serialize_date_fields #{env.inspect}"
      end

      def update(env)
        serialize_date_fields(env) && next_actor.update(env)
      end

      private

      def serialize_date_fields(env)
        puts "LOG_serialize_date_fields_AT_DateFieldsActor_Line_18 #{env.inspect}"
        env.curation_concern.class.date_fields.each do |field|
          puts "LOG_serialize_date_fields_AT_DateFieldsActor_Line_20_field #{field.inspect}"
          next if env.attributes[field].blank?

          env.attributes[field] = Array(env.attributes[field]).collect { |date_hash| transform_date(date_hash, field) }
          puts "LOG_serialize_date_fields_AT_DateFieldsActor_Line_24_env_attributes_field #{env.attributes[field].inspect}"
          env.attributes[field] = env.attributes[field].first unless env.curation_concern.class.multiple?(field)
          puts "LOG_serialize_date_fields_AT_DateFieldsActor_Line_26_env_attributes_field #{env.attributes[field].inspect}"
        end
      end

      def transform_date(date_hash, field)
        return date_hash unless date_hash.is_a? Hash

        date = date_hash["#{field}_year"]
        date << "-#{date_hash["#{field}_month"].to_i}" if date_hash["#{field}_month"].present?
        date << "-#{date_hash["#{field}_day"].to_i}" if date_hash["#{field}_month"].present? && date_hash["#{field}_day"].present?
        date
      end
    end
  end
end
