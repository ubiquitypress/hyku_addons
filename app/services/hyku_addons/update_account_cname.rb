# frozen_string_literal: true
require 'uri'

# Update the cname of an account.
class HykuAddons::UpdateAccountCname
  attr_reader :account
  attr_reader :cname

  ##
  # @param account [Account]
  # @param cname [String] Must be a valid cname
  def initialize(account, cname)
    @account = account
    @cname = cname
  end

  ##
  # @return [Boolean] true if validations pass and was able to update the account
  def perform
    valid? && update_account_cname
  end

  def valid?
    @account&.valid? && valid_cname?(@cname)
  end

  ##
  # update the cname references of the @account
  def update_account_cname
    @account.update cname: @cname
  end

  protected

    def valid_cname?(hostname)
      URI.parse("http://#{hostname}")&.host == hostname
    rescue URI::InvalidURIError
      false
    end
end
