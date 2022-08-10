# frozen_string_literal: true

module HykuAddons
  module AdminUserControllerBehavior
    extend ActiveSupport::Concern

    # Delete a user from the site
    def destroy
      if @user.present? && @user.works_count.zero?
        @user.destroy
        redirect_to hyrax.admin_users_path, notice: t("hyrax.admin.users.destroy.success", user: @user)
      elsif @user.present? && @user.uploaded_files.present? || @user.works_count.positive?
        handle_user_with_works(@user)
      else
        redirect_to hyrax.admin_users_path flash: { error: t("hyrax.admin.users.destroy.failure", user: @user) }
      end
    end

    private

    def handle_user_with_works(user)
      user.roles.clear
      user.add_role("inactive", Site.instance)
      redirect_to hyrax.admin_users_path, notice: t("hyrax.admin.users.destroy.success", user: user)
    end
  end
end
