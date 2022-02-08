# frozen_string_literal: true

module HykuAddons
  module UserBehavior
    extend ActiveSupport::Concern

    PROFILE_VISIBILITY = { open: "open", closed: "closed" }.freeze

    included do
      before_save :toggle_display_profile

      validate :email_format

      scope :with_public_profile, -> { where(display_profile: true) }
    end

    def display_profile_visibility
      PROFILE_VISIBILITY[display_profile ? :open : :closed]
    end

    protected

    # Triggered when the user registers an account
    def email_format
      email_formats = Site.account&.settings&.dig("email_format")

      return if email_formats.blank? || email_formats.include?("@#{email.split("@").last}")

      message = "must contain #{email_formats.to_sentence(two_words_connector: " or ", last_word_connector: ", or ")}"
      errors.add(:email, message)
    end

    def toggle_display_profile
      return unless display_profile_changed?

      HykuAddons::ToggleDisplayProfileJob.perform_later(email, display_profile_visibility)
    end
  end
end
