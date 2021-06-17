# frozen_string_literal: true

module Hyrax
  module Orcid
    class WorkOrcidExtractor
      include HykuAddons::WorkFormNameable
      include Hyrax::Orcid::OrcidHelper

      # TARGET_TERMS = %i[creator contributor].freeze
      TARGET_TERMS = %i[creator].freeze

      def initialize(work)
        @work = work
        @orcids = []

        validate!
      end

      def extract
        target_terms.each do |term|
          target = "#{term}_orcid"
          json = json_for_term(term)

          JSON.parse(json).select { |person| person.dig(target).present? }.each do |person|
            @orcids << validate_orcid(person.dig(target))
          end
        end

        @orcids.compact.uniq
      end

      def target_terms
        (TARGET_TERMS & work_type_terms)
      end

      protected

      def json_for_term(term)
        @work.send(term).first
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
