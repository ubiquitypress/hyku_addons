# frozen_string_literal: true

module Hyrax
  module Orcid
    class NotifyAllStrategy
      include Hyrax::Orcid::UrlHelper

      def initialize(work, identity)
        @work = work
        @identity = identity
      end

      def perform; end
    end
  end
end
