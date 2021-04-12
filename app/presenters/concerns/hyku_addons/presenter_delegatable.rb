# frozen_string_literal: true

module HykuAddons
  module PresenterDelegatable
    extend ActiveSupport::Concern

    def self.delegated_methods
      raise NotImplementedError, "delegated_methods must return an array of method names"
    end

    included do
      delegate(*delegated_methods, to: :solr_document)
    end
  end
end
