# frozen_string_literal: true

module HykuAddons
  module PortableBulkraxImporterBehavior
    extend ActiveSupport::Concern

    def portable_object
      puts "Bulkrax Importer"
      Bulkrax::Importer.find(arguments[0])
    rescue
      nil
    end
  end
end

