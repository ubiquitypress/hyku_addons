# frozen_string_literal: true

require "spec_helper"

RSpec.describe HykuAddons::ArrayFieldToSingleField do
  describe "UnaArchivalItem" do
    context "can return array field as single" do
      subject(:una_archival_item) { UnaArchivalItem.new }

      UnaArchivalItem::ARRAYTURNEDSINGLEFIELD.each do |field|
        it "returns #{field} as string" do
          expect(una_archival_item.send(field)).to eq ""
        end
      end
    end
  end
end
