# frozen_string_literal: true

# Overrides Hyku API user show method to allow users to take into account of added setting
module HykuAddons
  module UserControllerBehavior
    extend ActiveSupport::Concern

    def show
      user = User.find_by(email: params[:email])
      @user = user if user.display_profile == true
      render json: { status: 404, code: 'not_found', message: "This User is private" } if @user.nil?
    rescue ActiveRecord::RecordNotFound
      render json: { error: { status: '400', code: 'not_found', message: "Could not find user with 'id'=#{params[:id]}" } }
    end
  end
end
