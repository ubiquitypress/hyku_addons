# frozen_string_literal: true
module HykuAddons
  class CsvAdminSetEntry < Bulkrax::CsvCollectionEntry
    def factory_class
      AdminSet
    end
  end
end
