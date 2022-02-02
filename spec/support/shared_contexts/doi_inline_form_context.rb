# frozen_string_literal: true

RSpec.shared_examples "a DOI-enabled inline form" do
  subject { form }

  describe "properties" do
    it { is_expected.to delegate_method(:doi).to(:model) }

    it "includes properties in the list of terms" do
      expect(form.terms).to include(:doi)
    end

    it "does not include properties in secondary terms but does in the primary" do
      expect(form.primary_terms).to include(:doi)
      expect(form.secondary_terms).not_to include(:doi)
    end
  end
end
