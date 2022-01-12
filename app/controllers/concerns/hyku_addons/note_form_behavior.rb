# frozen_string_literal: true

module HykuAddons
  module NoteFormBehavior
    extend ActiveSupport::Concern

    included do
      self.terms += [:note]

      delegate :note, to: :model
    end

    class_methods do
      def build_permitted_params
        super.tap { |permitted_params| permitted_params << [:note] }
      end
    end
  end
end
