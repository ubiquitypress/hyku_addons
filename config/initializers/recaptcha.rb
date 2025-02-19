# frozen_string_literal: true
require "recaptcha/rails"

Recaptcha.configure do |config|
  config.site_key = ENV["RECAPTCHA_SITE_KEY"]
  config.secret_key = ENV["RECAPTCHA_SECRET_KEY"]
end
