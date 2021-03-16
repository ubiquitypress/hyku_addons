# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HykuAddons::FileSignedUrlService do
  let(:test_url) { "http://test123.com/file.jpg" }
  let(:hash) { "742e7a47-6780-4780-b561-4bd89738c56f" }
  let(:file) { double(Hydra::PCDM::File, { digest: "test:file:#{hash}" }) }

  describe "#new" do
    it "requires a valid file argument" do
      expect { described_class.new }.to raise_error(ArgumentError)
      expect { described_class.new(file: Class.new) }.to raise_error(ArgumentError)
      expect { described_class.new(file: file) }.not_to raise_error
    end
  end

  describe "#perform" do
    subject { described_class.new(file: file) }
    let(:bucket_mock) { double(Google::Cloud::Storage::Bucket, file: file_mock) }
    let(:file_mock) { double(Google::Cloud::Storage::File, signed_url: test_url) }
    let(:storage_mock) { double(Google::Cloud::Storage, bucket: bucket_mock) }

    before do
      allow(subject).to receive(:storage).and_return(storage_mock)
    end

    it "returns the file signed_url" do
      expect(subject.perform).to eq test_url
    end
  end
end

