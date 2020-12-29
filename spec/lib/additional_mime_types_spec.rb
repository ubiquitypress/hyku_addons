RSpec.describe "Additionao Mime Types" do
  describe "RIS" do
    it "is registered" do
      expect(Mime::Type.lookup("application/x-research-info-systems")).to be_a(Mime::Type)
      expect(Mime::Type.lookup_by_extension(:ris)).to be_a(Mime::Type)
    end
  end
end
