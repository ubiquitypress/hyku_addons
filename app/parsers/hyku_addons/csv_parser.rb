# frozen_string_literal: true
module HykuAddons
  class CsvParser < Bulkrax::CsvParser
    # FIXME: Override to make debugging easier
    def perform_method
      return :perform_now unless Rails.env.production?
      super
    end

    def file_paths
      raise StandardError, 'No records were found' if records.blank?
      @file_paths ||= records.map do |r|
        file_mapping = Bulkrax.field_mappings.dig(self.class.to_s, 'file', :from)&.first&.to_sym || :file
        next unless r[file_mapping].present?

        r[file_mapping].split(/\s*[:;|]\s*/).map do |f|
          # HACK: Override the tr method to prevent spaces from being changes to underscores
          file = File.join(path_to_files, f.tr(' ', ' '))
          if File.exist?(file) # rubocop:disable Style/GuardClause
            file
          else
            raise "File #{file} does not exist"
          end
        end
      end.flatten.compact.uniq
    end

    # @todo - investigate getting directory structure
    # @todo - investigate using perform_later, and having the importer check for
    #   DownloadCloudFileJob before it starts
    def retrieve_cloud_files(files)
      files_path = File.join(path_for_import, 'files')
      FileUtils.mkdir_p(files_path) unless File.exist?(files_path)
      files.each_pair do |_key, file|
        # fixes bug where auth headers do not get attached properly
        if file['auth_header'].present?
          file['headers'] ||= {}
          file['headers'].merge!(file['auth_header'])
        end
        # this only works for uniquely named files
        # HACK: Override the tr method to prevent spaces from being changes to underscores
        target_file = File.join(files_path, file['file_name'].tr(' ', ' '))
        # Now because we want the files in place before the importer runs
        # Problematic for a large upload
        Bulkrax::DownloadCloudFileJob.perform_now(file, target_file)
      end
      return nil
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
          id: collection,
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

    def path_to_files
      ENV['BULKRAX_FILE_PATH'].presence || super
    end

    # Override to use #entries_to_export for better handling of limiting
    def write_files
      CSV.open(setup_export_file, "w", headers: export_headers, write_headers: true) do |csv|
        entries_to_export.each do |e|
          csv << e.parsed_metadata
        end
      end
    end

    # All possible column names
    def export_headers
      # Trust that the entries' parsed metadata
      entries_to_export.map { |e| e.parsed_metadata.keys }.flatten.uniq
    end

    def entries_to_export
      entries_to_export = importerexporter.entries.where(identifier: current_work_ids)
      entries_to_export = if limit&.positive?
                            entries_to_export.limit(limit)
                          else
                            entries_to_export.limit(total)
                          end
      entries_to_export
    end

    # See https://stackoverflow.com/questions/2650517/count-the-number-of-lines-in-a-file-without-reading-entire-file-into-memory
    #   Changed to grep as wc -l counts blank lines, and ignores the final unescaped line (which may or may not contain data)
    def total
      # Reevaluate if total is not set or is 0
      return @total if @total&.positive?
      @total = if importer?
                 # @total ||= `wc -l #{parser_fields['import_file_path']}`.to_i - 1
                 `grep -vc ^$ #{parser_fields['import_file_path']}`.to_i - 1
               elsif exporter?
                 importerexporter.entries.count
               else
                 0
               end
    rescue StandardError
      @total = 0
    end
  end
end
