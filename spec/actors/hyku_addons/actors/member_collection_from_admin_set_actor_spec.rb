# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::Actors::MemberCollectionFromAdminSetActor do
  let(:user) { build(:user) }
  let(:ability) { ::Ability.new(user) }
  let(:work) { build(:generic_work) }
  let(:admin_set) { build(:admin_set, id: "admin_set_1") }
  let(:attributes) { {} }
  let(:env_class) { Hyrax::Actors::Environment }
  let(:env) { env_class.new(work, ability, attributes) }
  let(:terminator) { Hyrax::Actors::Terminator.new }

  # This is an alternative to the subject(:middleware) below, but won't test the middleware chain.
  # Use it with: `actor.create(env)`
  #
  # let(:actor) { described_class.new(terminator) }

  subject(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end

    stack.build(terminator)
  end

  before do
    allow(Flipflop).to receive(:enabled?).and_call_original
    allow(Flipflop).to receive(:enabled?).with(:simplified_admin_set_selection).and_return(true)
  end

  describe "#create" do
    it "called the terminator" do
      expect(terminator).to receive(:create).with(env_class)

      middleware.create(env)
    end
  end
end
