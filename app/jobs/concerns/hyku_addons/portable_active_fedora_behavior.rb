# frozen_string_literal: true

module HykuAddons
  module PortableActiveFedoraBehavior
    extend ActiveSupport::Concern

    def portable_object
      puts "AF portable object"
      ActiveFedora::Base.find(arguments[0])
    rescue
      nil
    end
  end
end
