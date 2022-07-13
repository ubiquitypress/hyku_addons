# frozen_string_literal: true

module HykuAddons
  module HyraxLeaseActorOverride
    extend ActiveSupport::Concern

    # Update the visibility of the work to match the correct state of the embargo, then clear the embargo date, etc.
    # Saves the embargo and the work
    def destroy
      # duplicating visibility because sometimes it is
      # not set correctly after expiration
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
