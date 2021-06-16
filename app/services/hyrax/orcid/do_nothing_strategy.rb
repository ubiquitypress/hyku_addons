# frozen_string_literal: true

# This strategy exists so that the user doens't need to remove the authorisation to prevent works being synced,
# or notifications being added to their account, which could be annoying, but still be able to have their
# personal/professional history shown on the public profile,
module Hyrax
  module Orcid
    class DoNothingStrategy
      def initialize(work, identity)
        @work = work
        @identity = identity
      end

      def perform; end
    end
  end
end

