# frozen_string_literal: true

module HykuAddons
  module AdminUserControllerBehavior
    extend ActiveSupport::Concern

    # Delete a user from the site
    def destroy
      return handle_user_with_only_files(@user) if @user&.works_count&.zero? && @user&.uploaded_files&.present?
      return handle_user_with_works(@user) if @user.works_count.positive?
      handle_users_without_works(@user) if @user&.uploaded_files&.empty? || @user&.works_count&.zero?
    end

    private

      def handle_user_with_works(user)
        if user.present?
          user.roles.clear
          user.add_role("inactive", Site.instance)
          redirect_to hyrax.admin_users_path, notice: t("hyrax.admin.users.destroy.success", user: user)
        else
          redirect_to hyrax.admin_users_path flash: { error: t("hyrax.admin.users.destroy.failure", user: user) }
        end
      end

      def handle_user_with_only_files(user)
        if user.uploaded_files.clear && user.destroy
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
