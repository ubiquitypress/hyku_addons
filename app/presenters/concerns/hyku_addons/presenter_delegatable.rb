# frozen_string_literal: true

module HykuAddons
  module PresenterDelegatable
    extend ActiveSupport::Concern

    def self.delegated_methods
      raise NotImplementedError, "delegated_methods must return an array of method names"
    end

    included do
      delegate(*delegated_methods, to: :solr_document)

      # NOTE:
      # I hate this being here, and wonder if it wouldn't be better to just include it on every
      # presenter than needs to delegate isbn?
      alias_method :isbns, :isbn if respond_to?(:delegated_methods) && delegated_methods.include?(:isbn)
    end
  end
end
