# frozen_string_literal: true

module HykuAddons
  class DateMonthService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('date_month', model: model)
    end
  end
end
