# frozen_string_literal: true

module HykuAddons
  module UserBehavior
    extend ActiveSupport::Concern

    PROFILE_VISIBILITY = { open: "open", closed: "closed" }.freeze

    included do
      before_save :toggle_display_profile
      before_create :add_default_roles

      validate :email_format

      # added so we can soft delete a user with a file by setting the user to inactive
      has_many :uploaded_files, class_name: "Hyrax::UploadedFile"

      # copied from hyku models/users to ensure inactive users are not in users page
      scope :for_repository, -> { joins(:roles).where.not(roles: { name: "inactive" }) }
      scope :with_public_profile, -> { where(display_profile: true) }
    end

    # _obj is required but is not used
    def mailboxer_email(_obj)
      email
    end

    def display_profile_visibility
      PROFILE_VISIBILITY[display_profile ? :open : :closed]
    end

    # overrides a devise method. devise gem checks for this method before sign_in a user
    # used to prevent signin by user with role inactive, that is soft deleted user
    def active_for_authentication?
      super && (inactive? != true)
    end

    # from devise gem
    # message a soft deleted user attempts to sign_in
    def inactive_message
      inactive? ? super : "Please contact your adminstrator"
    end

    # check if a user has been soft deleted
    def inactive?
      roles.map(&:name).include? "inactive"
    end

    def works_count
      ActiveFedora::SolrService.count("depositor_ssim:#{email} AND has_model_ssim:*")
    end

    protected

      # Triggered when the user registers an account
      def email_format
        email_formats = Site.account&.settings&.dig("email_format")

        return if email_formats.blank? || email_formats.include?("@#{email.split('@').last}")

        message = "Email must contain #{email_formats.to_sentence(two_words_connector: ' or ', last_word_connector: ' or ')}"
        errors.add(:email, message)
      end

      def toggle_display_profile
        return unless display_profile_changed?

        HykuAddons::ToggleDisplayProfileJob.perform_later(email, display_profile_visibility)
      end

      # copied over from hyku models/user.rb
      # If this user is the first user on the tenant, they become its admin
      # unless we are in the global tenant
      def add_default_roles
        return if Account.global_tenant?

        add_role :admin, Site.instance unless self.class.joins(:roles).where("roles.name = ?", "admin").any?
        # Role for any given site
        add_role :registered, Site.instance
      end
  end
end
