# frozen_string_literal: true

# Overrides Hyku API user show method to allow users to take into account of added setting
module HykuAddons
  module UsersControllerBehavior
    extend ActiveSupport::Concern

    def index
      @users = User.where(display_profile: true)
      @user_count = @users.count
    end

    def show
      @user = User.find_by(email: params[:email], display_profile: true)
      render json: { status: 403, code: 'forbidden', message: t("errors.users_forbidden") } if @user.blank?
    end
  end
end
