# frozen_string_literal: true

# https://github.com/samvera-labs/hyrax-doi/blob/main/app/actors/hyrax/actors/doi_actor.rb#L18
module Hyrax
  module Actors
    class OrcidActor < AbstractActor
      include HykuAddons::WorkFormNameable

      TARGET_TERMS = %i[creator contributor].freeze

      def create(env)
        process_work(env) && next_actor.create(env)
      end

      def update(env)
        process_work(env) && next_actor.update(env)
      end

      protected

        def process_work(env)
          @curation_concern = env.curation_concern

          (TARGET_TERMS & work_type_terms).each do |term|
            data = JSON.parse(@curation_concern.send(term).first)

            Array.wrap(data).each do |contributor|
              next unless (orcid = contributor.dig("#{term}_orcid"))

              byebug
            end
          end
        end

      private

        # Required for WorkFormNameable to function correctly
        def meta_model
          @curation_concern.class.name
        end
    end
  end
end
