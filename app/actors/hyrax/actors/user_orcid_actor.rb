# frozen_string_literal: true

# https://github.com/samvera-labs/hyrax-doi/blob/main/app/actors/hyrax/actors/doi_actor.rb#L18
module Hyrax
  module Actors
    class UserOrcidActor < AbstractActor
      include HykuAddons::WorkFormNameable

      def create(env)
        @curation_concern = env.curation_concern
        # byebug
        next_actor.create(env)
      end

      def update(env)
        @curation_concern = env.curation_concern
        # byebug
        next_actor.update(env)
      end

      protected

      def process
        terms.each do |term|
          creator = JSON.parse(@curation_concern.send(term).first)
        end
      end

      # Required for WorkFormNameable to function correctly
      def meta_model
        @curation_concern.class.name
      end

      def terms
        # Find the difference to ensure they are present in the form class terms
        %i[creator contributor] & work_type_terms
      end
    end
  end
end
