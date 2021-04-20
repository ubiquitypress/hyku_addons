# frozen_string_literal: true

module HykuAddons
  module Actors
    class MemberCollectionFromAdminSetActor < Hyrax::Actors::AbstractActor
      def create(env)
        ensure_collection!(env) if enabled?

        next_actor.create(env)
      end

      def update(env)
        ensure_collection!(env) if enabled?

        next_actor.update(env)
      end

      protected

      def enabled?
        Flipflop.enabled?(:simplified_admin_set_selection)
      end

      def ensure_collection!(env)
        title = AdminSet.find(env.attributes.dig("admin_set_id")).title.first
        collection = Collection.where(title: title)
        env.curation_concern.member_of_collections << collection
      end
    end
  end
end
