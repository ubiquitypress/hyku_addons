# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::GoogleCloudSignedUrlService do
  let(:work) { GenericWork.new(title: ["Moomin"]) }
  let(:uri) { "http://fcrepo:8080/fcrepo/rest/03e177db-2341-4edc-886d-06e32c08ce1e/d6/fa/cd/be/d6facdbe-da76-47ef-8544-555b8acf0523/files/a535989e-f65c-4d77-8a5e-ed64ebc6d8ae" }
  let(:file_class) { Hydra::PCDM::File }
  let(:file) do
    file = file_class.new
    file.uri = uri

    file
  end

  it "doesn't raise an error when the correct object is provided" do
    expect { described_class.new(file: file) }.not_to raise_error(RuntimeError)
  end

  it "raises an error when the wrong object type is provided" do
    expect { described_class.new(file: work) }.to raise_error(RuntimeError)
  end
end
