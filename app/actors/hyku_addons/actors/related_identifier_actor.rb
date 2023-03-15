# frozen_string_literal: true
module HykuAddons
  module Actors
    class RelatedIdentifierActor < Hyrax::Actors::AbstractActor
      def create(env)
        puts "LOG_CREATE_AT_RelatedIdentifierActor_BEFORE_add_related_identifier_data #{env.inspect}"
        add_related_identifier_data(env) && next_actor.create(env)
        puts "LOG_CREATE_AT_RelatedIdentifierActor_AFTER_add_related_identifier_data #{env.inspect}"
      end

      def update(env)
        add_related_identifier_data(env) && next_actor.update(env)
      end

      private

      def add_related_identifier_data(env)
        puts "LOG_add_related_identifier_data_AT_RelatedIdentifierActor_Line_18 #{env.inspect}"
        puts "LOG_add_related_identifier_data_AT_RelatedIdentifierActor_Line_19_class #{env.curation_concern.class.to_s.inspect}"
        return true unless env.curation_concern.class.to_s.include? "Redlands"
        puts "LOG_add_related_identifier_data_AT_RelatedIdentifierActor_Line_21 #{env.inspect}"
        identifier_hash = JSON.parse(env.attributes[:related_identifier].first).first if env.attributes[:related_identifier].present?
        puts "LOG_add_related_identifier_data_AT_RelatedIdentifierActor_Line_23 #{env.inspect}"
        puts "LOG_add_related_identifier_data_AT_RelatedIdentifierActor_Line_24_identifier_hash #{identifier_hash.inspect}"
        env.attributes[:related_identifier] = Array.wrap(add_related_metadata(identifier_hash))
        puts "LOG_add_related_identifier_data_AT_RelatedIdentifierActor_Line_26 #{env.inspect}"
      end

      def add_related_metadata(identifier_hash)
        return unless identifier_hash.present? && identifier_hash["related_identifier"].present?
        identifier_hash["related_identifier_type"] = "PMID"
        identifier_hash["relation_type"] = "HasMetadata"
        Array.wrap(identifier_hash).to_json
      end
    end
  end
end
