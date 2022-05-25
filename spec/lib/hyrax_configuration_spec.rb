# frozen_string_literal: true

RSpec.describe Hyrax do
  describe ".config" do
    it "registered the license service" do
      expect(described_class.config.license_service_class).to eq(HykuAddons::LicenseService)
    end

    context "Registered Curation Concerns" do
      let(:curation_concerns) do
        [GenericWork, Image, AnschutzWork, Article, Book, BookContribution, ConferenceItem, Dataset, DenverArticle,
         DenverBook, DenverBookChapter, DenverDataset, DenverImage, DenverMap, DenverMultimedia,
         DenverPresentationMaterial, DenverSerialPublication, DenverThesisDissertationCapstone, ExhibitionItem,
         NsuGenericWork, NsuArticle, Report, TimeBasedMedia, ThesisOrDissertation, PacificArticle, PacificBook,
         PacificImage, PacificThesisOrDissertation, PacificBookChapter, PacificMedia, PacificNewsClipping,
         PacificPresentation, PacificTextWork, PacificUncategorized, RedlandsArticle, RedlandsBook,
         RedlandsChaptersAndBookSection, RedlandsConferencesReportsAndPaper, RedlandsOpenEducationalResource,
         RedlandsMedia, RedlandsStudentWork, UbiquityTemplateWork, UnaArchivalItem, UnaArticle, UnaBook,
         UnaChaptersAndBookSection, UnaExhibition, UnaImage, UnaPresentation, UnaThesisOrDissertation,
         UnaTimeBasedMedia, UvaWork, UngArticle, UngBook, UngBookChapter, UngDataset, UngImage]
      end

      it "registered the correct curation concerns" do
        expect(described_class.config.curation_concerns).to match_array(curation_concerns)
      end
    end

    context "Registered callbacks" do
      it "registered the taskmaster callback" do
        expect(described_class.config.callback.enabled).to include(:task_master_after_create_fileset)
      end
    end
  end
end
