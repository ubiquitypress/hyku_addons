# frozen_string_literal: true

module Hyrax
  module Orcid
    class AskAllStrategy
      include Hyrax::OrcidHelper

      def initialize(work, identity)
        @work = work
        @identity = identity
      end

      def perform

      end
    end
  end
end

