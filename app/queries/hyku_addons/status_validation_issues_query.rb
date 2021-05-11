# frozen_string_literal: true
module HykuAddons
  class StatusValidationIssuesQuery < HykuAddons::BaseQuery
    def initialize(relation = Bulkrax::Status.all)
      super(relation)
    end

    def call(field = nil)
      scope = relation
              .where(status_message: 'Complete', error_message: nil)
              .where.not(error_backtrace: nil)
      field.blank? ? scope : scope.where("error_backtrace LIKE ?", "%#{field}%")
    end
  end
end
