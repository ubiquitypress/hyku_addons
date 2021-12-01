# frozen_string_literal: true

require "rails_helper"
require "pathname"
require "mini_magick"

RSpec.describe MiniMagick::Image do
  let(:file_path) { HykuAddons::Engine.root.join("spec", "fixtures", "pdf", "valid.pdf") }

  it "doesn't raise an error when opening the PDF" do
    expect(Pathname.new(file_path).exist?).to be_truthy
    expect { described_class.open(file_path) }.not_to raise_error
  end
end
