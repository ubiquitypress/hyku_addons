# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificArticle`
require 'rails_helper'

RSpec.describe Hyrax::Actors::PacificArticleActor do
  it "behaves like a BaseActor" do
    expect(described_class).to be < Hyrax::Actors::BaseActor
  end
end
