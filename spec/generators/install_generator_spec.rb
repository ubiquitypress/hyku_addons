# frozen_string_literal: true
require "rails_helper"
# Generators are not automatically loaded by Rails
require "generators/hyku_addons/install_generator"

RSpec.describe HykuAddons::InstallGenerator, type: :generator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination HykuAddons::Engine.root.join("tmp", "generator_testing")

  before do
    # This will wipe the destination root dir
    prepare_destination
  end

  it "runs" do
    run_generator
  end
end
