# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::Actors::MemberCollectionFromAdminSetActor do
  let(:rand) { SecureRandom.uuid }
  let(:attributes) { {} }
  let(:flipflop_name) { :simplified_admin_set_selection }
  let(:user) { build(:user) }
  let(:ability) { ::Ability.new(user) }
  let(:work) { create(:generic_work) }
  let(:env_class) { Hyrax::Actors::Environment }
  let(:env) { env_class.new(work, ability, attributes) }
  let(:terminator) { Hyrax::Actors::Terminator.new }

  let(:admin_set) { create(:admin_set, id: "admin_set_1", title: ["Test Name #{rand}"]) }
  # let(:admin_set_2) { create(:admin_set, id: "admin_set_2", title: ["Test Name Two"]) }

  # TODO: Update this to use the `collection_lw` because this legacy factory is super slow
  let(:collection) { create(:collection, title: ["Test Name #{rand}"]) }

  # This is an alternative to the subject(:middleware) below, but won't test the middleware chain.
  # Use it with: `actor.create(env)`
  #
  # let(:actor) { described_class.new(terminator) }

  let(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end

    stack.build(terminator)
  end

  before do
    allow(Flipflop).to receive(:enabled?).and_call_original
    allow(Flipflop).to receive(:enabled?).with(flipflop_name).and_return(true)
  end

  context "when the flipflop is enabled" do
    let(:attributes) { { admin_set_id: admin_set.id } }

    describe "#create" do
      it "called the terminator" do
        expect(terminator).to receive(:create).with(env_class)

        middleware.create(env)
      end

      context "" do
        let(:rand) { SecureRandom.uuid }

        # Create these two at the same time and ensure their titles match
        before do
          collection
          admin_set
        end

        it "adds the work to the collection" do
          expect(work.member_of_collections).to be_empty
          middleware.create(env)
          expect(work.member_of_collections).not_to be_empty
          expect(work.member_of_collections).to include(collection)
        end
      end

    end
  end

  context "when the flipflop is disabled" do
    before do
      allow(Flipflop).to receive(:enabled?).with(flipflop_name).and_return(false)
    end

    describe "create" do
      it "calls the termintor" do
        allow(terminator).to receive(:create)
        middleware.create(env)
        expect(terminator).to have_received(:create).with(env_class)
      end

      it "doesn't call ensure_collection!" do
        allow(middleware).to receive(:ensure_collection!)
        middleware.create(env)
        expect(middleware).not_to have_received(:ensure_collection!)
      end
    end
  end
end
