# frozen_string_literal: true

module Hyrax
  module Orcid
    class ProcessWorkService
      include HykuAddons::WorkFormNameable
      include Hyrax::Orcid::UrlHelper

      # TARGET_TERMS = %i[creator contributor].freeze
      TARGET_TERMS = %i[creator].freeze

      def initialize(work)
        @work = work

        validate!
      end

      # If the work includes our default processable terms
      def perform
        return unless Flipflop.enabled?(:orcid_identities)

        target_terms.each do |term|
          target = "#{term}_orcid"
          json = json_for_term(term)

          JSON.parse(json).select { |person| person.dig(target).present? }.each do |person|
            orcid_id = validate_orcid(person.dig(target))

            perform_user_strategy(orcid_id)
          end
        end
      end

      protected

        # A factory method for building the appropriate class depending on the users work sync preference
        def perform_user_strategy(orcid_id)
          return unless (identity = OrcidIdentity.find_by(orcid_id: orcid_id)).present?

          # TODO: Put this in a configuration object
          action = "perform_#{Rails.env.development? ? 'now' : 'later'}"
          Hyrax::Orcid::PerformIdentityStrategyJob.send(action, @work, identity)
        end

        def json_for_term(term)
          @work.send(term).first
        end

        def target_terms
          (TARGET_TERMS & work_type_terms)
        end

      private

        # Required for WorkFormNameable to function correctly
        def meta_model
          @work.class.name
        end

        def validate!
          raise ArgumentError, "A work is required" unless @work.is_a?(ActiveFedora::Base)
        end
    end
  end
end
