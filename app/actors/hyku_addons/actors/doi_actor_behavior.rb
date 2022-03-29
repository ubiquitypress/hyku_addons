# frozen_string_literal: true
module HykuAddons
  module Actors
    module DOIActorBehavior
      extend ActiveSupport::Concern

      private

        def doi_enabled_work_type?(_work)
          true
        end
    end
  end
end
