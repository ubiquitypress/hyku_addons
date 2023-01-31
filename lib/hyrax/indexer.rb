# frozen_string_literal: true

module Hyrax
  ##
  # @api public
  #
  # Build an indexer module from a schema. Generates custom indexer behavior
  # from rules provided by `index_loader`.
  #
  # @param [Symbol] schema_name
  # @param [#index_rule_for] index_loader
  #
  # @return [Module]
  #
  # @example building a module as a mixin
  #
  #   class MyIndexer < Hyrax::ValkyrieIndexer
  #     include Hyrax::Indexer(:core_metadata)
  #   end
  #
  # @since 3.0.0
  def self.Indexer(schema_name, index_loader: SimpleSchemaLoader.new)
    Indexer.new(index_loader.index_rules_for(schema: schema_name))
  end

  ##
  # @api private
  #
  # @see .Indexer
  class Indexer < Module
    ##
    # @param [Hash{Symbol => Symbol}] rules
    def initialize(rules)
      @rules = rules
    end

    private

    def included(descendant)
      descendant.alias_method(:resource, :object)
      rules = @rules

      define_method :generate_solr_document do |*args|
        super(*args).tap do |document|
          Array(rules).each { |index_key, method| document[index_key.to_s] = resource.try(method) }
        end
      end
    end
  end
end
