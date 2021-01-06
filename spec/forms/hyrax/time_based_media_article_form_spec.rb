require 'rails_helper'

RSpec.describe Hyrax::TimeBasedMediaArticleForm do
  let(:work) { GenericWork.new }
  let(:form) { described_class.new(work, nil, nil) }

  describe ".required_fields" do
    subject { form.required_fields }

    it { is_expected.to eq %i[title resource_type creator institution license] }
  end

  describe ".primary_terms" do
    subject { form.primary_terms }

    it { is_expected.to eq %i[title resource_type creator institution license] }
  end

  describe ".secondary_terms" do
    subject { form.secondary_terms }

    it do
      terms = [
        :title, :creator, :visibilty, :visibility_during_embargo, :visibility_after_embargo,
        :embargo_release_date, :visibility_during_lease, :visibility_after_lease, :lease_expiration_date
      ]
      is_expected.not_to include(terms)
    end
  end

  describe ".model_attributes" do
    let(:attributes) { { title: ['foo'], abstract: 'abstract' } }
    let(:params) { ActionController::Parameters.new(attributes) }
    subject(:model_attributes) { described_class.model_attributes(params) }

    it "permits parameters" do
      expect(model_attributes[:title]).to eq ['foo']
      expect(model_attributes[:abstract]).to eq 'abstract'
    end

    context '.model_attributes' do
      let(:attributes) { { title: [''], abstract: '', license: [''], on_behalf_of: 'Melissa' } }
      let(:params) { ActionController::Parameters.new(attributes)}

      it 'removes blank parameters' do
        expect(model_attributes[:title]).to be_empty
        expect(model_attributes[:abstract]).to be_nil
        expect(model_attributes[:license]).to be_empty
        expect(model_attributes[:on_behalf_of]).to eq 'Melissa'
      end
    end
  end

  include_examples("work_form")
end
