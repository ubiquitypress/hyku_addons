# frozen_string_literal: true

module HykuAddons
  module CollectionBehavior
    def collections
      records.map do |r|
        collection_ids(r)&.each_with_index&.map do |id, i|
          if r[collection_title_key].present?
            { id: collection_ids(r)[i], title: collection_titles(r)[i] }
          else
            { id: id, title: "New collection #{i + 1}" }
          end
        end
      end.flatten.compact.uniq
    end

    # Override to pass Bulkrax.system_identifier_field as singular instead of array
    def create_collections
      admin_sets.each_with_index do |admin_set_name, index|
        call_collection_job(admin_set_entry_class, admin_set_name, admin_set_metadata(admin_set_name))

        increment_counters(index, true)
      end

      collections.each_with_index do |collection, index|
        call_collection_job(collection_entry_class, collection[:id], collection_metadata(collection))

        increment_counters(index, true)
      end
    end

    def collections_total
      collections.size + admin_sets.size
    end

    private

      def call_collection_job(item_entry_class, item_id, item_metadata)
        return if item_id.empty?

        new_entry = find_or_create_entry(item_entry_class, item_id, "Bulkrax::Importer", item_metadata)

        begin
          HykuAddons::ImportWorkCollectionJob.perform_now(new_entry.id, current_run.id)
        rescue StandardError => e
          new_entry.status_info(e)
        end
      end

      def admin_set_metadata(admin_set)
        {
          title: [admin_set],
          # Allow Hyku to generate a UUID for the admin set
          # Bulkrax.system_identifier_field => nil,
          visibility: "open",
          collection_type_gid: Hyrax::CollectionType.find_or_create_admin_set_type.gid
        }
      end

      def collection_metadata(collection)
        {
          title: [collection[:title]],
          Bulkrax.system_identifier_field => collection[:id],
          id: collection[:id],
          visibility: "open",
          collection_type_gid: Hyrax::CollectionType.find_or_create_default_collection_type.gid
        }
      end

      def collection_delimiter
        Bulkrax.field_mappings["HykuAddons::CsvParser"]&.dig("collection", :split) || "\|"
      end

      def collection_prefix
        if Gem.loaded_specs["bulkrax"].version < Gem::Version.create("3.0")
          "collection"
        else
          "parent"
        end
      rescue
        "collection"
      end

      def collection_title_key
        "#{collection_prefix}_title".to_sym
      end

      def collection_titles(r)
        return [] unless r[collection_title_key].present?

        r[collection_title_key]&.split(collection_delimiter)
      end

      def collection_ids(r)
        return [] unless r[collection_prefix.to_sym].present?

        r[collection_prefix.to_sym]&.split(collection_delimiter)
      end
  end
end
