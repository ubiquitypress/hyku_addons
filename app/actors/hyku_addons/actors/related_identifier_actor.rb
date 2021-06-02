# frozen_string_literal: true
module HykuAddons
  module Actors
    class RelatedIdentifierActor < Hyrax::Actors::AbstractActor

      def create(env)
        add_related_identifier_data(env) && next_actor.create(env)
      end

      def update(env)
        add_related_identifier_data(env) && next_actor.update(env)
      end

      private

      def add_related_identifier_data(env)
        return unless env.curation_concern.class.to_s.include? "Redlands"
        identifier_hash = JSON.parse(env.attributes[:related_identifier].first).first
        env.attributes[:related_identifier] = [add_related_metadata(identifier_hash)]
      end

      def add_related_metadata(identifier_hash)
        return unless identifier_hash["related_identifier"].present?
        identifier_hash["related_identifier_type"] = "PMID"
        identifier_hash["relation_type"] = "HasMetadata"
        [identifier_hash].to_json
      end
    end
  end
end
