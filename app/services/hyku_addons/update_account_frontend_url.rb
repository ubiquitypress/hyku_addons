# frozen_string_literal: true
require 'uri'

# Update the frontend_url of an account.
class HykuAddons::UpdateAccountFrontendUrl
  attr_reader :account
  attr_reader :frontend_url

  ##
  # @param account [Account]
  # @param frontend_url [String] Must be a valid URI
  def initialize(account, frontend_url)
    @account = account
    @frontend_url = frontend_url
  end

  ##
  # @return [Boolean] true if validations pass and was able to update the account
  def perform
    valid? && update_account_frontend_url
  end

  def valid?
    @account&.valid? && valid_url?(@frontend_url)
  end

  ##
  # update the frontend_url references of the @account
  def update_account_frontend_url
    @account.update frontend_url: @frontend_url
  end

  protected

    def valid_url?(hostname)
      URI.parse("https://#{hostname}")&.host
    rescue URI::InvalidURIError
      false
    end
end
