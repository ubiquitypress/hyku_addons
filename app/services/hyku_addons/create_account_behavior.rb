# frozen_string_literal: true

module HykuAddons
  module CreateAccountBehavior
    def create_account_inline
      CreateAccountInlineJob.perform_now(account) && account.create_datacite_endpoint
    end
  end
end
