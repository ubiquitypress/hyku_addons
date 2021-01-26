# frozen_string_literal: true
module HykuAddons
  class CsvParser < Bulkrax::CsvParser
    def entry_class
      HykuAddons::CsvEntry
    end

    # Override to pass Bulkrax.system_identifier_field as singular instead of array
    def create_collections
      collections.each_with_index do |collection, index|
        next if collection.blank?
        metadata = {
          title: [collection],
          Bulkrax.system_identifier_field => collection,
          visibility: 'open',
          collection_type_gid: Hyrax::CollectionType.find_or_create_default_collection_type.gid
        }
        new_entry = find_or_create_entry(collection_entry_class, collection, 'Bulkrax::Importer', metadata)
        Bulkrax::ImportWorkCollectionJob.perform_now(new_entry.id, current_run.id)
        increment_counters(index, true)
      end
    end
  end
end
