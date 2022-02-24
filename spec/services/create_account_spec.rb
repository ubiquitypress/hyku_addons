# frozen_string_literal: true

RSpec.describe CreateAccount do
  subject(:instance) { described_class.new(account) }
  let(:account) { build(:sign_up_account) }

  it "has a create_account_inline method" do
    expect(instance).to respond_to(:create_account_inline)
  end
end
