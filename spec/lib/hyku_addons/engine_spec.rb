# frozen_string_literal: true

RSpec.describe HykuAddons::Engine do
  describe "Additional mime types" do
    it "RIS is registered" do
      expect(Mime::Type.lookup("application/x-research-info-systems")).to be_a(Mime::Type)
      expect(Mime::Type.lookup_by_extension(:ris)).to be_a(Mime::Type)
    end
  end

  describe "setting the session store" do
    it "sets the correct session store" do
      expect(Rails.application.config.session_options).to eq(cookie_only: true, key: "_hyku_session", same_site: :lax)
    end
  end

  describe "adding Flipflop features" do
    it "adds the engine to the flipflop paths" do
      path = described_class.root.join("config", "features.rb").to_s

      expect(Flipflop::FeatureLoader.current.instance_variable_get(:@paths)).to include(path)
    end
  end
end
