# frozen_string_literal: true

module HykuAddons
  module BulkFlagBehavior


    def find_or_create_entry(entryclass, identifier, type, raw_metadata = nil)
      entry = entryclass.where(
        importerexporter_id: importerexporter.id,
        importerexporter_type: type,
        identifier: identifier
      ).first_or_create!
      entry.raw_metadata = raw_metadata
      entry.bulk = entry.current_batch_size > 1
      entry.save!
      entry
    end

  end
end