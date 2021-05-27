# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::Actors::NoteFieldActor do
  let(:rand) { SecureRandom.uuid }
  let(:attributes) { {} }
  let(:user) { build(:user) }
  let(:ability) { ::Ability.new(user) }
  let(:work) { create(:generic_work) }
  let(:env_class) { Hyrax::Actors::Environment }
  let(:env) { env_class.new(work, ability, attributes) }
  let(:terminator) { Hyrax::Actors::Terminator.new }

  # let(:actor) { described_class.new(terminator) }

  # This lets us use the middleware chain, rather than assuming its running and using the `create` method on the actor
  let(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end

    stack.build(terminator)
  end

  describe "#create" do
    context "when the note attribute is present" do
      let(:attributes) { { note: 'this is a note' } }

      before do
        allow(terminator).to receive(:create).with(env)
        allow(middleware).to receive(:serialize_note_field).with(env_class)
      end

      it "call serialize_note_field method while creating work" do
        middleware.create(env)
        expect(middleware).to have_received(:serialize_note_field).with(env)
      end

      it "returns an ActiveTriples::Relation class for note attribute" do
        middleware.create(env)
        expect(work.note.class).to eq(ActiveTriples::Relation)
      end
    end
  end

  describe "#update" do
    let(:generic_work) { create(:generic_work, title: ["Test Name #{rand}"], note: ['my first note']) }
    let(:env) { env_class.new(generic_work, ability, attributes) }
    let(:attributes) { { note: 'this is a new note' } }

    context "when the note attribute is present" do
      before do
        allow(terminator).to receive(:update).with(env)
      end

      it "call the update method " do
        middleware.update(env)
        expect(terminator).to have_received(:update).with(env_class)
      end
    end
  end
end
