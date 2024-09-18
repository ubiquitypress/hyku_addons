# frozen_string_literal: true

module HykuAddons
  module NotesTabFormHelper
    def form_tabs_for(form:)
      return super unless Flipflop.enabled?(:notes_tab_form) && form.model.respond_to?(:note)

      super + ["notes"]
    end

    def sort_note_hash(note_attr)
      note_attr.map { |json| JSON.parse(json) }.sort_by { |hash| DateTime.parse(hash["timestamp"]).to_i }
    end
  end
end
