# frozen_string_literal: true
RSpec.describe "hyrax/file_sets/_actions.html.erb", type: :view do
  let(:solr_document) { instance_double(SolrDocument, id: "file_set_id", hydra_model: ::FileSet) }
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
      render "hyrax/file_sets/actions", file_set: file_set
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
      render "hyrax/file_sets/actions", file_set: file_set
    end

    it "allows the user to edit the file" do
      expect(rendered).to have_css("a#file_destroy")
    end
  end

  context "with download permission" do
    before do
      allow(view).to receive(:can?).with(:download, file_set.id).and_return(true)
    end

    context "with annotation disabled" do
      before do
        allow(Flipflop).to receive(:enabled?).with(:annotation).and_return(false)
      end

      it "includes google analytics data in the download link" do
        render "hyrax/file_sets/actions", file_set: file_set

        expect(rendered).to have_css("a#file_download")
        expect(rendered).to have_selector("a[data-label=\"#{file_set.id}\"]")
      end

      it "does not allow the user to read and annotate the file" do
        expect(rendered).not_to have_css("a#file_read")
      end
    end

    context "with annotation enabled" do
      before do
        allow(Flipflop).to receive(:enabled?).with(:annotation).and_return(true)
      end

      context "when the file is a pdf" do
        before do
          allow(file_set).to receive(:pdf?).and_return(true)
        end

        it "allows the user to read and annotate the file" do
          render "hyrax/file_sets/actions", file_set: file_set

          expect(rendered).to have_css("a#file_read")
          expect(rendered).to have_selector("a[href=\"#{hyku_addons.pdf_viewer_path('file_set_id')}\"]")
        end
      end

      context "when the file is a not  pdf" do
        before do
          allow(file_set).to receive(:pdf?).and_return(false)
          render "hyrax/file_sets/actions", file_set: file_set
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
  end

  context "with no permission" do
    context "with annotation disabled" do
      before do
        allow(Flipflop).to receive(:enabled?).with(:annotation).and_return(false)
        allow(file_set).to receive(:pdf?).and_return(true)
        render "hyrax/file_sets/actions", file_set: file_set
      end

      it "renders nothing" do
        expect(strip_tags(rendered).squish).to be_empty
      end
    end

    context "with annotation enabled" do
      before do
        allow(Flipflop).to receive(:enabled?).with(:annotation).and_return(true)
      end

      context "when the file is a pdf" do
        before do
          allow(file_set).to receive(:pdf?).and_return(true)
          render "hyrax/file_sets/actions", file_set: file_set
        end

        it "allows the user to read and annotate the file" do
          render "hyrax/file_sets/actions", file_set: file_set

          expect(rendered).to have_css("a#file_read")
          expect(rendered).to have_selector("a[href=\"#{hyku_addons.pdf_viewer_path('file_set_id')}\"]")
        end
      end

      context "when the file is a not pdf" do
        before do
          allow(file_set).to receive(:pdf?).and_return(false)
          render "hyrax/file_sets/actions", file_set: file_set
        end

        it "renders nothing" do
          expect(strip_tags(rendered).squish).to be_empty
        end
      end
    end
  end
end
