# frozen_string_literal: true

RSpec.describe HykuAddons do
  describe 'version' do
    it 'is has a version' do
      expect(described_class::VERSION).to be_present
    end
  end
end
