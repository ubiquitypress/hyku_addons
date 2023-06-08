# frozen_string_literal: true
module HykuAddons
  module WorksControllerBehavior
    extend ActiveSupport::Concern

    # Override the create class method to allow tracing
    def create
      trace = TracePoint.trace(:return) do |tp|
        #if tp.defined_class.is_a?(Hyrax::Actors::AbstractActor)
        if tp.defined_class.to_s.include?("Actor") #temporary hack until i figure out what sort of class this is
          puts "actor_trace -> #{tp.path}:#{tp.defined_class}.#{tp.method_id} returned #{tp.return_value}"
        end
      end

      actor_response = nil # placeholder

      trace.enable do
        actor_response = actor.create(actor_environment)
      end

      if actor_response
        after_create_response
      else
        respond_to do |wants|
          wants.html do
            build_form
            render 'new', status: :unprocessable_entity
          end
          wants.json { render_json_response(response_type: :unprocessable_entity, options: { errors: curation_concern.errors }) }
        end
      end
    end

    included do
      include HykuAddons::WorksControllerAdditionalMimeTypesBehavior
      # Add other includes here
    end
  end
end
