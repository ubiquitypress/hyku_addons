# frozen_string_literal: true
module HykuAddons
  class RightsStatementService < QaSelectService
    def initialize(model: nil)
      super('rights_statements', model: model)
    end
  end
end
