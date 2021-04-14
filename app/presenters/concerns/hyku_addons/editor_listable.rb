# frozen_string_literal: true

module HykuAddons
  module EditorListable
    extend ActiveSupport::Concern

    def editor_list
      @editor_list ||= person_or_organization_list(:editor)
    end
  end
end
