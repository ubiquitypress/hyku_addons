# frozen_string_literal: true

RSpec.describe Hyrax::Actors::TimeBasedMediaActor do
  it "behaves like a BaseActor" do
    expect(described_class).to be < Hyrax::Actors::BaseActor
  end
end
