# frozen_string_literal: true

RSpec.describe "OAI PMH Support", type: :feature do
  let(:user)    { create(:user) }
  let(:account) { create(:account, user: user) }
  let(:work)    { create(:work, user: user) }
  let(:identifier) { work.id }

  before do
    login_as(user, scope: :user)
    work
  end

  context 'oai interface with works present' do
    it "shows extended metadata"
  end
end
