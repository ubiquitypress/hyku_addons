# frozen_string_literal: true

module HykuAddons
  class DateYearService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('date_year', model: model)
    end
  end
end
