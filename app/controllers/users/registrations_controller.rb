# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action :check_recaptcha, only: [:create]

  private

  def check_recaptcha
    unless verify_recaptcha
      self.resource = resource_class.new(sign_up_params)
      flash[:alert] = "reCAPTCHA verification failed. Please try again."
      respond_with_navigational(resource) { render :new }
    end
  end
end
