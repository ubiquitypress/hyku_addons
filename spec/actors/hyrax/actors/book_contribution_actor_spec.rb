# Generated via
#  `rails generate hyrax:work BookContribution`
require 'rails_helper'

RSpec.describe Hyrax::Actors::BookContributionActor do
  it "behaves like a BaseActor" do
    expect(Hyrax::Actors::BookContributionActor).to be < Hyrax::Actors::BaseActor
  end
end
