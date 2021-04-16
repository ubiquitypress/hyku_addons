# frozen_string_literal: true

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
          return unless Flipflop.enabled?(:orcid_identities)

          @curation_concern = env.curation_concern

          (TARGET_TERMS & work_type_terms).each { |term| process_term(term) }
        end

        def process_term(term)
          data = @curation_concern.send(term).first

          return unless data.present?

          JSON.parse(data).each do |participant|
            next unless (orcid_id = participant.dig("#{term}_orcid")).present?

            Hyrax::Orcid::ProcessWorkJob.perform_later(orcid_id, @curation_concern)
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
