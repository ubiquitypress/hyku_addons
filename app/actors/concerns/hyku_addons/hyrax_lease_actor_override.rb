# frozen_string_literal: true

module HykuAddons
  module HyraxLeaseActorOverride
    extend ActiveSupport::Concern

    # Ensure the visibility of the work matches the correct state of the embargo, then clear the embargo date, etc.
    # Persist the lease and the work
    def destroy
      # should correctly set work visibility after lease expiration
      visibility_after = work.visibility_after_lease.clone

      work.lease_visibility! # If the lease has lapsed, update the current visibility.
      work.deactivate_lease!
      work.lease.save!
      # set visibility if incorrect
      work.visibility = visibility_after if work.visibility != visibility_after
      work.save!
    end
  end
end
