# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::Actors::MemberCollectionFromAdminSetActor do
  let(:rand) { SecureRandom.uuid }
  let(:attributes) { {} }
  let(:flipflop_name) { :simplified_admin_set_selection }
  let(:user) { build(:user) }
  let(:ability) { ::Ability.new(user) }
  let(:work) { build_stubbed(:generic_work) }
  let(:env_class) { Hyrax::Actors::Environment }
  let(:env) { env_class.new(work, ability, attributes) }
  let(:terminator) { Hyrax::Actors::Terminator.new }

  # TODO: Update this to use the `collection_lw` because this legacy factory is super slow
  let(:collection) { build_stubbed(:collection, title: ["Test Name #{rand}"]) }

  # This is an alternative to the subject(:middleware) below, but won't test the middleware chain.
  # Use it with: `actor.create(env)`
  #
  # let(:actor) { described_class.new(terminator) }

  # This lets us use the middleware chain, rather than assuming its running and using the `create` method on the actor
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

  describe "#create" do
    let(:admin_set) { create(:admin_set, id: "admin_set_1", title: ["Test Name #{rand}"]) }

    context "when the flipflop is enabled" do
      let(:attributes) { { admin_set_id: admin_set.id } }

      before do
        allow(terminator).to receive(:create).with(env_class)
      end

      it "called the terminator" do
        middleware.create(env)

        expect(terminator).to have_received(:create).with(env_class)
      end

      context "when a collection exists" do
        let(:rand) { SecureRandom.uuid }
        let(:work) { create(:generic_work) }
        let(:collection) { create(:collection, title: ["Test Name #{rand}"]) }

        # Create these two at the same time and ensure their titles match by using the same `rand`
        before do
          collection
          admin_set
        end

        it "adds the correct work to the collection" do
          expect(work.member_of_collections).to be_empty

          middleware.create(env)

          expect(work.member_of_collections).not_to be_empty
          expect(work.member_of_collections).to include(collection)
          expect(work.member_of_collections.first.title.first).to eq admin_set.title.first
        end
      end

      context "when no collection exists with a matching title" do
        let(:rand) { SecureRandom.uuid }

        before do
          admin_set
        end

        it "adds the correct work to the collection" do
          expect(work.member_of_collections).to be_empty

          middleware.create(env)

          expect(work.member_of_collections).to be_empty
        end
      end
    end

    context "when the user is an admin" do
      let(:attributes) { { admin_set_id: admin_set.id } }

      before do
        # TODO: Workout how to get upstream hyku factories so this isn't required and we can use `build(:admin)`
        user.add_role(:admin)

        allow(terminator).to receive(:create)
        allow(middleware).to receive(:ensure_collection!)
      end

      it "calls the terminator" do
        middleware.create(env)

        expect(terminator).to have_received(:create).with(env_class)
      end

      it "doesn't call ensure_collection!" do
        middleware.create(env)

        expect(middleware).not_to have_received(:ensure_collection!)
      end
    end

    context "when the flipflop is disabled" do
      before do
        allow(Flipflop).to receive(:enabled?).with(flipflop_name).and_return(false)

        allow(terminator).to receive(:create)
        allow(middleware).to receive(:ensure_collection!)
      end

      it "calls the termintor" do
        middleware.create(env)

        expect(terminator).to have_received(:create).with(env_class)
      end

      it "doesn't call ensure_collection!" do
        middleware.create(env)

        expect(middleware).not_to have_received(:ensure_collection!)
      end
    end
  end

  describe "#update" do
    let(:admin_set) { build_stubbed(:admin_set, id: "admin_set_1", title: ["Test Name #{rand}"]) }

    context "when the flipflop is enabled" do
      let(:attributes) { { admin_set_id: admin_set.id } }

      before do
        allow(Flipflop).to receive(:enabled?).with(flipflop_name).and_return(false)

        allow(terminator).to receive(:create).with(env_class)
      end

      it "called the terminator" do
        middleware.create(env)

        expect(terminator).to have_received(:create).with(env_class)
      end
    end

    context "when the flipflop is disabled" do
      before do
        allow(Flipflop).to receive(:enabled?).with(flipflop_name).and_return(false)

        allow(terminator).to receive(:create).with(env_class)
      end

      it "called the terminator" do
        middleware.create(env)

        expect(terminator).to have_received(:create).with(env_class)
      end
    end
  end
end
