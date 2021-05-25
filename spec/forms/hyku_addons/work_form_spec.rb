# frozen_string_literal: true
require 'rails_helper'

RSpec.describe HykuAddons::WorkForm do
  let(:form) { form_class.new(work, nil, nil) }
  let(:form_class) { Hyrax::GenericWorkForm }
  let(:work) { GenericWork.new }

  describe "#primary_terms" do
    subject { form.primary_terms }

    it { is_expected.not_to include :admin_set_id }

    context 'with simplified_admin_set_selection enabled' do
      before do
        allow(Flipflop).to receive(:enabled?).and_call_original
        allow(Flipflop).to receive(:enabled?).with(:simplified_admin_set_selection).and_return(true)
      end

      it { is_expected.to include :admin_set_id }
    end

    context 'with RedlandsArticle' do
      let(:form_class) { Hyrax::RedlandsArticleForm }
      let(:work) { RedlandsArticle.new }

      it { is_expected.not_to include :admin_set_id }

      context 'with simplified_admin_set_selection enabled' do
        before do
          allow(Flipflop).to receive(:enabled?).and_call_original
          allow(Flipflop).to receive(:enabled?).with(:simplified_admin_set_selection).and_return(true)
        end

        it { is_expected.to include :admin_set_id }
      end
    end
  end
end
