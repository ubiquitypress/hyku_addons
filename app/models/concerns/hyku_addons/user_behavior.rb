# frozen_string_literal: true

module HykuAddons
  module UserBehavior
    extend ActiveSupport::Concern

    included do
      around_update :toggle_display_profile
      validate :must_have_valid_email_format
    end

    def must_have_valid_email_format
      accepted_email_formats = current_account&.settings&.dig('email_format')
      return unless accepted_email_formats.present?

      email_format = '@' + email.split('@')[-1]
      errors.add(:email, "Email must contain #{accepted_email_formats.join(', ')}") unless accepted_email_formats.include? email_format
    end

    def current_account
      Site.account
    end

    def display_profile_visibility
      user.display_profile ? "open" : "closed"
    end

    def toggle_display_profile
      return unless display_profile_changed?
      yield
      HykuAddons::ToggleDisplayProfileJob.perform_later(email, display_profile_visibility)
    end
  end
end
