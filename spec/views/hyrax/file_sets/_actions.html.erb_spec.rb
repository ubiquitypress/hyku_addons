# frozen_string_literal: true
RSpec.describe 'hyrax/file_sets/_actions.html.erb', type: :view do
  let(:solr_document) { instance_double(SolrDocument, id: 'file_set_id', hydra_model: ::FileSet) }
  let(:user) { build(:user) }
  let(:ability) { Ability.new(user) }
  let(:file_set) { Hyrax::FileSetPresenter.new(solr_document, ability) }

  before do
    allow(controller).to receive(:current_ability).and_return(ability)
    allow(file_set).to receive(:parent).and_return(:parent)
    allow(view).to receive(:can?).with(:edit, file_set.id).and_return(false)
    allow(view).to receive(:can?).with(:destroy, file_set.id).and_return(false)
    allow(view).to receive(:can?).with(:download, file_set.id).and_return(false)
  end

  context "with edit permission" do
    before do
      allow(view).to receive(:can?).with(:edit, file_set.id).and_return(true)
      render 'hyrax/file_sets/actions', file_set: file_set
    end

    it "allows the user to edit the file" do
      expect(rendered).to have_css("a#file_edit")
    end

    it "allows the user to view the file versions" do
      expect(rendered).to have_css("a#file_versions")
    end
  end

  context "with destroy permission" do
    before do
      allow(view).to receive(:can?).with(:destroy, file_set.id).and_return(true)
      render 'hyrax/file_sets/actions', file_set: file_set
    end

    it "allows the user to edit the file" do
      expect(rendered).to have_css("a#file_destroy")
    end
  end

  context "with download permission" do
    before do
      allow(view).to receive(:can?).with(:download, file_set.id).and_return(true)
    end

    context "when the file is a pdf" do
      before do
        allow(file_set).to receive(:pdf?).and_return(true)
        render 'hyrax/file_sets/actions', file_set: file_set
      end

      it "includes google analytics data in the download link" do
        expect(rendered).to have_css("a#file_download")
        expect(rendered).to have_selector("a[data-label=\"#{file_set.id}\"]")
      end

      it "allows the user to read and annotate the file" do
        expect(rendered).to have_css("a#file_read")
        expect(rendered).to have_selector("a[href=\"https://via.hypothes.is/viewer/web/viewer.html?http://test.host/downloads/file_set_id\"]")
      end
    end

    context "when the file is a not  pdf" do
      before do
        allow(file_set).to receive(:pdf?).and_return(false)
        render 'hyrax/file_sets/actions', file_set: file_set
      end

      it "includes google analytics data in the download link" do
        expect(rendered).to have_css("a#file_download")
        expect(rendered).to have_selector("a[data-label=\"#{file_set.id}\"]")
      end

      it "does not allow the user to read and annotate the file" do
        expect(rendered).not_to have_css("a#file_read")
      end
    end
  end

  context "with no permission" do
    before do
      render 'hyrax/file_sets/actions', file_set: file_set
    end

    it "renders nothing" do
      expect(rendered).to eq("")
    end
  end
end
