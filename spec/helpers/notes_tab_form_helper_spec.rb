# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::NotesTabFormHelper, type: :helper do
  include Devise::Test::ControllerHelpers

  let(:user) { build_stubbed(:user) }
  let(:work) { GenericWork.new(title: ["Moomin"], depositor: user.user_key) }
  let(:form) { Hyrax::GenericWorkForm.new(work, nil, nil) }
  let(:helper) { _view }
  let(:note_hash) do
    [
      { timestamp: "2021-05-26 00:05:12 UTC", note: "Second" }.to_json,
      { timestamp: "2021-05-25 00:07:12 UTC", note: "First" }.to_json,
      { timestamp: "2021-05-27 00:05:12 UTC", note: "Third" }.to_json
    ]
  end

  before do
    allow(Flipflop).to receive(:enabled?).and_call_original
    allow(Flipflop).to receive(:enabled?).with(:notes_tab_form).and_return(true)
    allow(controller).to receive(:current_user) { user }
  end

  describe "#sort_note_hash" do
    it "returns an array of note hashes in sorted order" do
      sorted_note_hash = helper.sort_note_hash(note_hash)

      expect(sorted_note_hash).to be_an(Array)
      expect(sorted_note_hash.collect { |note_hash| note_hash["note"] }).to eq(["First", "Second", "Third"])
    end
  end

  describe "#form_tabs_for" do
    context "when the work type does not have a notes field on the work" do
      context "when the feature is enabled" do
        it "shows the notes tab" do
          expect(helper.form_tabs_for(form: form)).to include("notes")
        end
      end

      context "when the feature is disabled" do
        before do
          allow(Flipflop).to receive(:enabled?).with(:notes_tab_form).and_return(false)
        end

        it "doesn not show the notes tab" do
          expect(helper.form_tabs_for(form: form)).not_to include("notes")
        end
      end
    end

    context "when the work type does not have a notes field on the work" do
      let(:work) { GenericWork.new(title: ["Moomin"], depositor: user.user_key) }
      let(:form) { Hyrax::GenericWorkForm.new(work, nil, nil) }

      before do
        allow(work).to receive(:respond_to?).with(:note).and_return(false)
      end

      context "when the feature is enabled" do
        it "does not show the notes tab" do
          expect(helper.form_tabs_for(form: form)).not_to include("notes")
        end
      end

      context "when the feature is disabled" do
        before do
          allow(Flipflop).to receive(:enabled?).with(:notes_tab_form).and_return(false)
        end

        it "doesn not show the notes tab" do
          expect(helper.form_tabs_for(form: form)).not_to include("notes")
        end
      end
    end
  end
end
