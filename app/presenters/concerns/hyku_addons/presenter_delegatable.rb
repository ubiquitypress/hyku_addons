# frozen_string_literal: true

module HykuAddons
  module PresenterDelegatable
    extend ActiveSupport::Concern

    def self.delegated_methods
      raise NotImplementedError, "delegated_methods must return an array of method names"
    end

    included do
      # Check if any other concerns have registered methods before delegating, which prevents
      # concerns like Hyrax::DOI::DOIPresenterBehavior trying to register a helper `doi` method
      # which is not called, as we already delegated the method and it could not be overwritten.
      delegated_methods.each { |method| delegate(method, to: :solr_document) unless instance_methods.include?(method) }

      # NOTE:
      # I hate this being here, and wonder if it wouldn't be better to just include it on every
      # presenter than needs to delegate isbn?
      alias_method :isbns, :isbn if respond_to?(:delegated_methods) && delegated_methods.include?(:isbn)
    end
  end
end
