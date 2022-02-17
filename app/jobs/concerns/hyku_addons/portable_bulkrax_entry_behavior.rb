# frozen_string_literal: true

module HykuAddons
  module PortableBulkraxEntryBehavior
    extend ActiveSupport::Concern

    def portable_object
      puts "Bulkrax Portable"
      # byebug
      Bulkrax::Entry.find(arguments[0])
    rescue
      nil
    end
  end
end
