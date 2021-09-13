# frozen_string_literal: true

# Universal methods to work out the names and terms for a work form
module HykuAddons
  module WorkFormNameable
    extend ActiveSupport::Concern

    def work_class(meta_model)
      @_work_class ||= meta_model.constantize
    end

    def work_form_class(meta_model)
      @_work_form_class ||= "Hyrax::#{meta_model}Form".constantize
    end

    def work_type_terms(meta_model)
      @_work_type_terms ||= work_form_class(meta_model).terms
    end
  end
end
