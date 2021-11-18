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
      user = User.find_by(email: params[:email])
      @user = user if user.present? && user.display_profile == true
      render json: { status: 404, code: 'not_found', message: "This User is either private or not found" } if @user.nil?
    rescue ActiveRecord::RecordNotFound
      render json: { error: { status: '400', code: 'not_found', message: "Could not find user with 'email'=#{params[:email]}" } }
    end
  end
end
