# frozen_string_litera: true

module HykuAddons
  module Actors
    class MemberCollectionFromAdminSetActor < Hyrax::Actors::AbstractActor
      def create(env)
        ensure_collection!(env)
        next_actor.create(env)
      end

      def update(env)
        ensure_collection!(env)
        next_actor.update(env)
      end

      protected

      def ensure_collection!(env)
        return unless Flipflop.enabled?(:simplified_admin_set_selection)

        # byebug
        # admin_set_id = params.dig("admin_set_id")
        # model = f.object.model.class.to_s.underscore
        # title = AdminSet.find(admin_set_id).title.first
        # collection_id = Collection.where(title: title).first&.id

      end
    end
  end
end
