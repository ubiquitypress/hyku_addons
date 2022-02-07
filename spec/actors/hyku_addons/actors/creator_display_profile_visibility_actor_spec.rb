# frozen_string_literal: true

require "spec_helper"

RSpec.describe HykuAddons::Actors::CreatorProfileVisibilityActor do
  let(:creator) do
    [
      {
        creator_name_type: "Personal",
        creator_family_name: "Hawking",
        creator_given_name: "Stephen",
        creator_institutional_email: user.email,
        creator_profile_visibility: User::PROFILE_VISIBILITY[:closed]
      }
    ].to_json
  end
  let(:work) { create(:work, creator: [creator]) }
  let(:account) { create(:account) }
  let(:site) { Site.new(account: account) }

  # Middleware Setup
  let(:attributes) { work.attributes }
  let(:user) { create(:user) }
  let(:ability) { ::Ability.new(user) }
  let(:env_class) { Hyrax::Actors::Environment }
  let(:env) { env_class.new(work, ability, attributes) }
  let(:terminator) { Hyrax::Actors::Terminator.new }
  let(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end

    stack.build(terminator)
  end
  let(:key) { "creator_profile_visibility" }

  before do
    allow(Site).to receive(:instance).and_return(site)
  end

  describe "#create" do
    before do
      allow(terminator).to receive(:create).with(env)
    end

    it "calls the next actor" do
      middleware.create(env)

      expect(terminator).to have_received(:create).with(env)
    end

    context "when the display profile is false" do
      it "doesn't change the value" do
        expect { middleware.create(env) }
          .not_to change { JSON.parse(env.attributes[:creator].first).first.dig(key) }
      end
    end

    context "when the display profile is true" do
      before do
        user.update(display_profile: true)
      end

      it "does change the value" do
        expect { middleware.create(env) }
          .to change { JSON.parse(env.attributes[:creator].first).first.dig(key) }
      end
    end
  end

  describe "#update" do
    before do
      allow(terminator).to receive(:update).with(env)
    end

    it "calls the next actor" do
      middleware.update(env)

      expect(terminator).to have_received(:update).with(env)
    end

    context "when the display profile is false" do
      it "doesn't change the value" do
        expect {  middleware.update(env) }
          .not_to change { JSON.parse(env.attributes[:creator].first).first.dig(key) }
      end
    end

    context "when the display profile is true" do
      before do
        user.update(display_profile: true)
      end

      it "does change the value" do
        expect {  middleware.update(env) }
          .to change { JSON.parse(env.attributes[:creator].first).first.dig(key) }
      end
    end
  end
end
