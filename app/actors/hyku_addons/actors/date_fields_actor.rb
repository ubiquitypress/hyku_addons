# frozen_string_literal: true
module HykuAddons
  module Actors
    class DateFieldsActor < Hyrax::Actors::AbstractActor
      def create(env)
        serialize_date_fields(env) && next_actor.create(env)
      end

      def update(env)
        serialize_date_fields(env) && next_actor.update(env)
      end

      private

      def serialize_date_fields(env)
        env.curation_concern.class.date_fields.each do |field|
          next if env.attributes[field].blank?

          env.attributes[field] = Array(env.attributes[field]).collect { |date_hash| transform_date(date_hash, field) }
          env.attributes[field] = env.attributes[field].first unless env.curation_concern.class.multiple?(field)
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
