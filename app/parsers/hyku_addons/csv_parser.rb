# frozen_string_literal: true
module HykuAddons
  class CsvParser < Bulkrax::CsvParser
    # FIXME: Override to make debugging easier
    def perform_method
      return :perform_now unless Rails.env.production?
      super
    end

    def entry_class
      HykuAddons::CsvEntry
    end

    def admin_set_entry_class
      HykuAddons::CsvAdminSetEntry
    end

    # Override to pass Bulkrax.system_identifier_field as singular instead of array
    def create_collections
      admin_sets.each_with_index do |admin_set_name, index|
        next if admin_set_name.blank?
        metadata = {
          title: [admin_set_name],
          # Allow Hyku to generate a UUID for the admin set
          # Bulkrax.system_identifier_field => nil,
          visibility: 'open',
          collection_type_gid: Hyrax::CollectionType.find_or_create_admin_set_type.gid
        }
        new_entry = find_or_create_entry(admin_set_entry_class, admin_set_name, 'Bulkrax::Importer', metadata)
        begin
          Bulkrax::ImportWorkCollectionJob.perform_now(new_entry.id, current_run.id)
        rescue StandardError => e
          new_entry.status_info(e)
        end
        increment_counters(index, true)
      end

      collections.each_with_index do |collection, index|
        next if collection.blank?
        metadata = {
          title: [collection],
          Bulkrax.system_identifier_field => collection,
          visibility: 'open',
          collection_type_gid: Hyrax::CollectionType.find_or_create_default_collection_type.gid
        }
        new_entry = find_or_create_entry(collection_entry_class, collection, 'Bulkrax::Importer', metadata)
        begin
          Bulkrax::ImportWorkCollectionJob.perform_now(new_entry.id, current_run.id)
        rescue StandardError => e
          new_entry.status_info(e)
        end
        increment_counters(index, true)
      end
    end

    def admin_sets
      # does the CSV contain an admin_set column?
      return [] unless import_fields.include?(:admin_set)
      # retrieve a list of unique admin sets
      records.map { |r| r[:admin_set] }.flatten.compact.uniq
    end

    def collections_total
      collections.size + admin_sets.size
    end
  end
end
