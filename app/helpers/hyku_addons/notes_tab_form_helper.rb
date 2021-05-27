# frozen_string_literal: true
module HykuAddons
  module NotesTabFormHelper
    def form_tabs_for(form:)
      if Flipflop.enabled?(:notes_tab_form)
        super + ['notes']
      else
        super
      end
    end

    def sort_note_hash(note_attribute)
      note_hash_ary = note_attribute.map do |note|
        JSON.parse(note)
      end
      note_hash_ary.sort_by { |note_hash| DateTime.parse(note_hash["timestamp"]).to_i }
    end
  end
end
