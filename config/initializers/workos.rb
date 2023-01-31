# frozen_string_literal: true
require "workos"

WorkOS.configure do |config|
  config.key = ENV["WORKOS_API_KEY"]
  config.timeout = 120
end
