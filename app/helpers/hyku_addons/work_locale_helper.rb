# frozen_string_literal: true

module HykuAddons
  module WorkLocaleHelper
    def get_work_locale(cname)
      AccountElevator.switch!(cname)
      Site.account.settings&.dig("locale_name")
    end
  end
end
