# frozen_string_literal: true
module HykuAddons
  module Actors
    module DOIActorBehavior
      extend ActiveSupport::Concern

      private

        def doi_enabled_work_type?(work)
          work.respond_to?(:doi) ? true : false
        end
    end
  end
end
