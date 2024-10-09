# frozen_string_literal: true

module HykuAddons
  module SiteBehavior
    extend ActiveSupport::Concern

    private

    # Add/invite admins via email address
    # @param [Array<String>] Array of user emails
    def add_admins_by_email(emails)
      Rails.logger.info("Starting add_admins_by_email for Site ID: #{self.id} with emails: #{emails.inspect}")

      # For users that already have accounts, add to role immediately
      existing_emails = User.where(email: emails).map do |u|
        Rails.logger.info("Assigning admin role to existing user: #{u.email}")
        u.add_role :admin, self
        u.email
      end

      Rails.logger.info("Existing users processed: #{existing_emails.inspect}")

      # For new users, send invitation and add to role
      (emails - existing_emails).each do |email|
        Rails.logger.info("Processing new user invitation for email: #{email}")

        unless self.account.enable_sso
          u = User.invite!(email: email)
          Rails.logger.info("Invitation sent to new user: #{email}")
        end

        u.add_role :admin, self if defined?(u) # safeguard to ensure 'u' is defined
        Rails.logger.info("Assigned admin role to new user: #{email}")
      end

      Rails.logger.info("Finished add_admins_by_email for Site ID: #{self.id}")
    rescue StandardError => e
      Rails.logger.error("Error in add_admins_by_email for Site ID: #{self.id} with emails: #{emails.inspect}: #{e.message}")
      raise
    end
  end
end
