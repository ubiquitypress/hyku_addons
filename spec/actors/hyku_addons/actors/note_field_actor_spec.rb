# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::Actors::NoteFieldActor do
  let(:rand) { SecureRandom.uuid }
  let(:attributes) { {} }
  let(:user) { build(:user) }
  let(:ability) { ::Ability.new(user) }
  let(:work) { build(:generic_work) }
  let(:env_class) { Hyrax::Actors::Environment }
  let(:env) { env_class.new(work, ability, attributes) }
  let(:terminator) { Hyrax::Actors::Terminator.new }

  # This lets us use the middleware chain, rather than assuming its running and using the `create` method on the actor
  let(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
      middleware.use Hyrax::Actors::ModelActor
    end

    stack.build(terminator)
  end

  describe "#create" do
    context "when the note attribute is present" do
      let(:attributes) { { note: "this is a note" } }

      before do
        allow(terminator).to receive(:create).with(env)
      end

      it "creates note from the the note attributes" do
        expect(work.note).to be_blank
        middleware.create(env)
        expect(work.note).to be_present
        note_hash = JSON.parse(work.note.first)
        expect(note_hash["email"]).to eq(user.email)
        expect(note_hash["note"]).to eq(attributes[:note])
      end
    end
  end

  describe "#update" do
    let(:work) do
      create(
        :generic_work,
        title: ["Test Name #{rand}"],
        note: ["{\"email\":\"email-1@test.com\",\"timestamp\":\"2021-05-27 23:15:23 UTC\",\"note\":\"first note\"}"]
      )
    end
    let(:attributes) { { note: "this is a new note" } }

    context "when the note attribute is present" do
      before do
        allow(terminator).to receive(:update).with(env)
      end

      it "append the new note attributes with previous note" do
        expect(work.note).to be_present
        expect(work.note.count).to eq(1)

        middleware.update(env)

        expect(work.note.count).to eq(2)
        note_content_ary = work.note.map do |note|
          JSON.parse(note)["note"]
        end
        expect(note_content_ary).to include(attributes[:note])
      end
    end
    context "when the note attribute is not present" do
      before do
        allow(terminator).to receive(:update).with(env)
      end

      let(:attributes) { { note: [] } }

      it "retains the previous note if note attributes are not present " do
        expect(work.note).to be_present
        expect(work.note.count).to eq(1)

        middleware.update(env)

        expect(work.note.count).to eq(1)
        note_content_ary = work.note.map do |note|
          JSON.parse(note)["note"]
        end
        expect(note_content_ary).to include("first note")
      end
    end
  end
end
