# frozen_string_literal: true

module Hyrax
  module Orcid
    class ProcessWorkService
      include HykuAddons::WorkFormNameable
      include Hyrax::OrcidHelper

      # TARGET_TERMS = %i[creator contributor].freeze
      TARGET_TERMS = %i[creator].freeze

      def initialize(work)
        @work = work

        validate!
      end

      # If the work includes our default processable terms
      def perform
        (TARGET_TERMS & work_type_terms).each do |term|
          target = "#{term}_orcid"

          JSON.parse(@work.send(term).first).select { |person| person.dig(target) }.each do |person|
            orcid_id = validate_orcid(person.dig(target))

            # If the user hasn't linked their account in this repository
            next unless (identity = OrcidIdentity.find_by(orcid_id: orcid_id)).present?

            sync_class(identity).new(work, identity).perform
          end
        end
      end

      private

      def sync_class(identity)
        "Hyrax::Orcid::#{identity.work_sync_preference.classify}".constantize
      end

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
