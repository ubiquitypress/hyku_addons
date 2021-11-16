# frozen_string_literal: true

RSpec.describe Proprietor::AccountsController, type: :controller, multitenant: true do
  let(:user) {}

  before do
    sign_in user if user
  end

  context "as an admin of a site" do
    let(:user) { FactoryBot.create(:user).tap { |u| u.add_role(:admin, Site.instance) } }
    let(:account) { FactoryBot.create(:account) }

    before do
      Site.update(account: account)
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) do
          { datacite_endpoint_attributes: { mode: "production", prefix: "10.1234", username: "user123", password: "pass123" } }
        end

        it "updates the requested account" do
          allow(Apartment::Tenant).to receive(:switch).with(account.tenant) do |&block|
            block.call
          end
          put :update, params: { id: account.to_param, account: new_attributes }
          account.reload
          expect(account.datacite_endpoint.mode).to eq "production"
          expect(account.datacite_endpoint.prefix).to eq "10.1234"
          expect(account.datacite_endpoint.username).to eq "user123"
          expect(account.datacite_endpoint.password).to eq "pass123"
          expect(response).to redirect_to([:proprietor, account])
        end
      end
    end
  end
end
