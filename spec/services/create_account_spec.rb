# frozen_string_literal: true

RSpec.describe CreateAccount do
  subject { described_class.new(account) }
  let(:account) { build(:sign_up_account) }

  it "has a create_account_inline method" do
    expect(subject).to respond_to(:create_account_inline)
  end
end

