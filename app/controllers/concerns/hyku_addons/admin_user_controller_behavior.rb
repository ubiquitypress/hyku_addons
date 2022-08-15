# frozen_string_literal: true

module HykuAddons
  module AdminUserControllerBehavior
    extend ActiveSupport::Concern

    # Delete a user from the site
    def destroy
      return handle_users_without_works(@user) if @user.present? && @user.works_count.zero?
      handle_user_with_works(@user)
    end

    private

      def handle_user_with_works(user)
        if user.present? && user.uploaded_files.present? || @user.works_count.positive?
          user.roles.clear
          user.add_role("inactive", Site.instance)
          redirect_to hyrax.admin_users_path, notice: t("hyrax.admin.users.destroy.success", user: user)
        else
          redirect_to hyrax.admin_users_path flash: { error: t("hyrax.admin.users.destroy.failure", user: user) }
        end
      end

      def handle_users_without_works(user)
        if user.destroy
          redirect_to hyrax.admin_users_path, notice: t("hyrax.admin.users.destroy.success", user: user)
        else
          redirect_to hyrax.admin_users_path flash: { error: t("hyrax.admin.users.destroy.failure", user: user) }
        end
      end
  end
end
