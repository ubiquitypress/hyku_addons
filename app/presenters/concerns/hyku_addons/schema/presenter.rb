# frozen_string_literal: true

module HykuAddons
  module Schema
    def self.Presenter(schema_name, schema_loader: Hyrax::SimpleSchemaLoader.new)
      Presenter.new(schema_loader.index_rules_for(schema: schema_name))
    end

    ##
    # @api private
    #
    class Presenter < Module
      ##
      # @param [Hash{Symbol => Symbol}] rules
      def initialize(rules)
        @rules = rules
      end

      private

        def included(descendant)
          rules = @rules
          descendant.define_singleton_method :delegated_methods do |*_args|
            rules.values.uniq
          end
        end
    end
  end
end
