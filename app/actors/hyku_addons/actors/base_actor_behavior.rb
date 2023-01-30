# frozen_string_literal: true

module HykuAddons
  module Actors
    module BaseActorBehavior
      private

      # Monkey-patch override to make use of file set parameters relating to permissions
      # See https://github.com/samvera/hyrax/pull/4992
      # Override to skip file_set attribute when doing mass assignment
      def clean_attributes(attributes)
        attributes[:license] = Array(attributes[:license]) if attributes.key? :license
        attributes[:rights_statement] = Array(attributes[:rights_statement]) if attributes.key? :rights_statement
        remove_blank_attributes!(attributes).except("file_set")
      end
    end
  end
end
