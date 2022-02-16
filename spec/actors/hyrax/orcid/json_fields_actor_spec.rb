# frozen_string_literal: true

RSpec.describe Hyrax::Actors::Orcid::JSONFieldsActor do
  it "isn't included in the middleware stack" do
    expect(Hyrax::CurationConcern.actor_factory.middlewares).not_to include(described_class)
  end
end
