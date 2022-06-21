# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::ApiDateHelper, type: :helper do
  let(:helper) { _view }
  let(:date) { "2022-6-1" }
  let(:incomplete_date) { "2017" }

  it "returns parsed date do" do
    expect(helper.format_api_date(date)).to eq "2022-06-01"
  end

  it "returns nil when no date given" do
    expect(helper.format_api_date("")).to be_falsey
  end

  it "returns date it cannot format" do
    expect(helper.format_api_date(incomplete_date)).to eq incomplete_date
  end
end
