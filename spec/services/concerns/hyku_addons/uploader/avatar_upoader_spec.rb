# frozen_string_literal: true

RSpec.describe HykuAddons::Uploader::AvatarUploader do
  subject(:uploader) { Hyrax::AvatarUploader.new }
  let(:store_dir) { Rails.public_path.join("system", ":attachment", ":id").to_s }
  let(:user) { create(:user, display_profile: true, avatar: file_fixture("up.png").open) }
  let(:account) { create(:account) }

  describe "avatar saves to public folder" do
    before do
      allow(Apartment::Tenant).to receive(:switch!).with(account.tenant) do |&block|
        block&.call
      end

      Apartment::Tenant.switch!(account.tenant) do
        Site.update(account: account)
        user
      end
    end

    it "returns correct store_dir path" do
      expect(uploader.store_dir).to eq store_dir
    end

    it "points to an actual file" do
      expect(user.avatar.current_path).to be_truthy
    end
  end
end
