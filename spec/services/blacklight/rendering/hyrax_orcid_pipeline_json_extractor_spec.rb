# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hyrax::Orcid::Blacklight::Rendering::PipelineJsonExtractor do
  it "isn't included in the middleware stack" do
    expect(Blacklight::Rendering::Pipeline.operations).not_to include(described_class)
  end
end

