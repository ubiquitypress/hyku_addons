module HykuAddons
  module NotesTabFormHelper
    def form_tabs_for(form:)
      if true #Flipflop.enabled?(:notes_tab_form)
        super + ['notes']
      else
        super
      end
    end

    def parse_note_content(note)
      JSON.parse(note)
    end
  end
end
