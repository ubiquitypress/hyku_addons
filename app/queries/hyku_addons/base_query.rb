# frozen_string_literal: true
module HykuAddons
  class BaseQuery
    attr_reader :relation

    def self.call(relation = nil, args)
      new(relation).call(*args)
    end

    def initialize(relation = nil)
      raise ArgumentError, "You must provide a base relation" unless relation.present?
      @relation = relation
    end
  end
end
