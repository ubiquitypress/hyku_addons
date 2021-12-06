# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work Article`
require "rails_helper"

RSpec.describe Hyrax::Actors::ArticleActor do
  it "behaves like a BaseActor" do
    expect(described_class).to be < Hyrax::Actors::BaseActor
  end
end
