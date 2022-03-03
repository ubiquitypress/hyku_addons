# frozen_string_literal: true

module HykuAddons
  module WorkLocaleHelper
    def get_work_locale(cname)
      Account.find_by(cname: cname).locale_name
    end
  end
end
