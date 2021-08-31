# frozen_string_literal: true

module HykuAddons
  module Actors
    class MemberCollectionFromAdminSetActor < Hyrax::Actors::AbstractActor
      def create(env)
        ensure_collection!(env) if enabled? && correct_permissions?(env)

        next_actor.create(env)
      end

      # We shouldn't be doing anything on update as the collection will be assigned on create
      delegate :update, to: :next_actor

      protected

        def ensure_collection!(env)
          admin_set_id = env.attributes.dig("admin_set_id")

          return unless admin_set_id.present?

          title = AdminSet.find(admin_set_id)&.title&.first
          collection = Collection.where(title: title).first if title.present?

          return unless collection.present?

          # Set reindexing to limited otherwise full nested reindexing runs which is really really expensive for large collections
          collection.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
          env.curation_concern.member_of_collections << collection
        end

      private

        # Admins do not need us to find their collections as they still have the admin interface
        def correct_permissions?(env)
          !env.current_ability.current_user.has_role?(:admin)
        end

        def enabled?
          Flipflop.enabled?(:simplified_admin_set_selection)
        end
    end
  end
end
