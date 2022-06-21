# frozen_string_literal: true

module HykuAddons
  module ApiDateHelper
    # @params [String] date eg "2022-6-1".
    # @return [String] date string eg  "2022-06-01" ot the string if it cannot format it.
    def format_api_date(date_string)
      return nil unless date_string.present?

      Date.parse(date_string).strftime("%Y-%m-%d")

    rescue Date::Error
      date_string
    end
  end
end
