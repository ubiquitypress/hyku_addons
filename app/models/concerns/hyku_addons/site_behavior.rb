# frozen_string_literal: true

module HykuAddons
  module SiteBehavior
    extend ActiveSupport::Concern
    
    private
    # Add/invite admins via email address
    # @param [Array<String>] Array of user emails
    def add_admins_by_email(emails)
      # For users that already have accounts, add to role immediately
      existing_emails = User.where(email: emails).map do |u|
        u.add_role :admin, self
        u.email
      end
      # For new users, send invitation and add to role
      (emails - existing_emails).each do |email|

        unless self.account.enable_sso
          u = User.invite!(email: email) 
        end

        u.add_role :admin, self
      end

    end

  end
end
