# frozen_string_literal: true

RSpec.describe ::Maremma do
  let(:response_body) { File.read(HykuAddons::Engine.root.join("spec", "fixtures", "maremma", "extracted_response_data.json")) }
  let!(:encode_response) { described_class.parse_response(response_body) }
  let(:parsed_response) { JSON.parse(encode_response) }
  let(:correct_title) { "\“We’re Not Invisible…We’re In Second Place.\” Disrupting (Thus Connecting) Transnational Gender Narratives Within Veterans Studies" }
  let(:non_english_character) { "Diario El d\xEDa Bolivia" }
  let!(:encode_non_english_character) { described_class.parse_response(non_english_character) }

  it "returns correct econding from overriden .parsed_response method" do
    expect(parsed_response["message"]["title"]&.first&.strip).to eq(correct_title)
  end

  it "does not handle non english characters eg 'dia' " do
    expect(encode_non_english_character).to eq("Diario El d?a Bolivia")
  end
end
