module HykuAddons
  class ImporterValidationIssuesQuery < HykuAddons::BaseQuery
    def initialize(relation = Bulkrax::Importer.all)
      super(relation)
    end

    def call(field = nil)
      relation.
        joins(entries: :latest_status).
        merge(HykuAddons::StatusValidationIssuesQuery.new.call(field))
    end
  end
end