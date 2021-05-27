# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::NotesTabFormHelper do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:work) { GenericWork.new(title: ["Moomin"], depositor: user.user_key) }
  let(:form) { Hyrax::GenericWorkForm.new(work, nil, nil) }
  let(:helper) { _view }
  let(:note_hash) do
    [
      { timestamp: "2021-05-26 00:05:12 UTC", note: "Second Note" }.to_json,
      { timestamp: "2021-05-25 00:07:12 UTC", note: "First Note" }.to_json,
      { timestamp: "2021-05-27 00:05:12 UTC", note: "Third Note" }.to_json
    ]
  end

  before do
    allow(Flipflop).to receive(:enabled?).with(:simplified_admin_set_selection).and_return(false)
    allow(Flipflop).to receive(:enabled?).with(:notes_tab_form).and_return(false)
    allow(controller).to receive(:current_user) { user }
  end

  describe "#form_tabs_for" do
    context "when the feature is enabled" do
      before do
        allow(Flipflop).to receive(:enabled?).with(:notes_tab_form).and_return(true)
        allow(helper).to receive(:form_tabs_for).with(form: form).and_return(['notes'])
      end

      it "shows the notes tab" do
        expect(helper.form_tabs_for(form: form)).to include("notes")
      end
    end

    context "when the feature is disabled" do
      before do
        allow(Flipflop).to receive(:enabled?).with(:notes_tab_form).and_return(false)
        allow(helper).to receive(:form_tabs_for).with(form: form).and_return(['relationships'])
      end

      it "doesn not show the notes tab" do
        expect(helper.form_tabs_for(form: form)).not_to include("notes")
      end
    end
  end

  describe "#sort_note_hash" do
    it "returns an array of note hashes in sorted order" do
      sorted_note_hash = helper.sort_note_hash(note_hash)
      expect(sorted_note_hash).to be_an(Array)
      expect(sorted_note_hash.collect { |note_hash| note_hash["note"] }).to eq(
        ["First Note", "Second Note", "Third Note"]
      )
    end
  end
end
