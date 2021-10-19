# frozen_string_literal: true

module HykuAddons
  class DateDayService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('date_day', model: model)
    end
  end
end
