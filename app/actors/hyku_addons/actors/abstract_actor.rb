# frozen_string_literal: true
module Hyrax
  module Actors
    module ActorExtensions
      def create(env)
        ret_val = super
        puts "actor_trace -> #{self.class.name} Return Value: #{ret_val}"
        ret_val
      end
    end

    class AbstractActor
      def self.inherited(child_class)
        puts "actor_trace NEW_CHILD_CLASS_INHERITED: #{child_class}"
        child_class.prepend(ActorExtensions)
      end
    end
  end
end