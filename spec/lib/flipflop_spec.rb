# frozen_string_literal: true

RSpec.describe Flipflop do
  let(:features_file_path) { HykuAddons::Engine.root.join("config", "features.rb") }
  let(:registered_features_paths) { Flipflop::FeatureLoader.current.instance_variable_get(:@paths) }

  it "is registered with the HykuAddons engine" do
    expect(registered_features_paths).to include(features_file_path.to_s)
  end
end
