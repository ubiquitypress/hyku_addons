# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Hyrax::GenericWorkForm do
  let(:work) { GenericWork.new }
  let(:form) { described_class.new(work, nil, nil) }

  describe ".required_fields" do
    subject { form.required_fields }

    it { is_expected.to eq [:title, :resource_type, :creator, :institution] }
  end

  describe ".primary_terms" do
    subject { form.primary_terms }

    it { is_expected.to eq [:title, :resource_type, :creator, :institution, :license] }
  end

  describe ".secondary_terms" do
    subject { form.secondary_terms }

    it do
      is_expected.not_to include(:title, :creator,
                                 :visibilty, :visibility_during_embargo,
                                 :embargo_release_date, :visibility_after_embargo,
                                 :visibility_during_lease, :lease_expiration_date,
                                 :visibility_after_lease, :collection_ids)
    end
  end

  describe ".model_attributes" do
    subject(:model_attributes) { described_class.model_attributes(params) }

    let(:params) { ActionController::Parameters.new(attributes) }
    let(:attributes) do
      {
        title: ['foo'],
        rendering_ids: ['file-set-id'],
        abstract: 'abstract'
      }
    end

    it 'permits parameters' do
      expect(model_attributes['title']).to eq ['foo']
      expect(model_attributes['rendering_ids']).to eq ['file-set-id']
      expect(model_attributes['abstract']).to eq 'abstract'
    end

    context '.model_attributes' do
      let(:params) do
        ActionController::Parameters.new(
          title: [''],
          abstract: '',
          keyword: [''],
          license: [''],
          on_behalf_of: 'Melissa'
        )
      end

      it 'removes blank parameters' do
        expect(model_attributes['title']).to be_empty
        expect(model_attributes['abstract']).to be_nil
        expect(model_attributes['license']).to be_empty
        expect(model_attributes['keyword']).to be_empty
        expect(model_attributes['on_behalf_of']).to eq 'Melissa'
      end
    end
  end

  include_examples("work_form")
end
