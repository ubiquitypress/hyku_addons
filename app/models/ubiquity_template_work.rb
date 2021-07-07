# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work TemplateWork`
class UbiquityTemplateWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Hyrax::DOI::DOIBehavior
  include Hyrax::DOI::DataCiteDOIBehavior
  include ::HykuAddons::WorkBase
  include ::HykuAddons::AltTitleMultiple
  include ::HykuAddons::AddInfoSingular

  property :location, predicate: ::RDF::Vocab::BF2.physicalLocation, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :subject_text, predicate: ::RDF::Vocab::DC.subject, multiple: true do |index|
    index.as :stored_searchable
  end

  property :place_of_publication, predicate: ::RDF::Vocab::BF2.term(:Place) do |index|
    index.as :stored_searchable, :facetable
  end

  property :mesh, predicate: ::RDF::Vocab::DC.term(:MESH) do |index|
    index.as :stored_searchable
  end

  property :journal_frequency, predicate: ::RDF::Vocab::DC.term(:Frequency), multiple: false do |index|
    index.as :stored_searchable
  end

  property :funding_description, predicate: ::RDF::Vocab::MARCRelators.spn do |index|
    index.as :stored_searchable
  end

  property :citation, predicate: ::RDF::Vocab::DC.term(:bibliographicCitation) do |index|
    index.as :stored_searchable
  end

  property :table_of_contents, predicate: ::RDF::Vocab::Bibframe.term(:tableOfContents), multiple: false do |index|
    index.as :stored_searchable
  end

  property :references, predicate: ::RDF::Vocab::DC.references do |index|
    index.as :stored_searchable
  end

  property :extent, predicate: ::RDF::Vocab::DC.extent, multiple: false do |index|
    index.as :stored_searchable
  end

  property :medium, predicate: ::RDF::Vocab::DC.medium do |index|
    index.as :stored_searchable
  end

  property :committee_member, predicate: ::RDF::Vocab::AS.term(:Person) do |index|
    index.as :stored_searchable
  end

  property :time, predicate: ::RDF::Vocab::DC.temporal do |index|
    index.as :stored_searchable
  end

  property :qualification_grantor, predicate: ::RDF::Vocab::BF2.grantingInstitution, multiple: false do |index|
    index.as :stored_searchable
  end

  property :qualification_name, predicate: ::RDF::Vocab::SCHEMA.qualifications, multiple: false do |index|
    index.as :stored_searchable
  end

  property :qualification_level, predicate: ::RDF::Vocab::BF2.degree, multiple: false do |index|
    index.as :stored_searchable
  end

  property :date_published_text, predicate: ::RDF::Vocab::DC.date, multiple: false do |index|
    index.as :stored_searchable
  end

  property :rights_statement_text, predicate: ::RDF::Vocab::DC.rights, multiple: false do |index|
    index.as :stored_searchable
  end

  property :qualification_subject_text, predicate: ::RDF::Vocab::HYDRA.subject, multiple: true do |index|
    index.as :stored_searchable
  end

  property :event_date, predicate: ::RDF::Vocab::Bibframe.eventDate do |index|
    index.as :stored_searchable
  end

  property :journal_title, predicate: ::RDF::Vocab::BIBO.Journal, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :alternative_journal_title, predicate: ::RDF::Vocab::SCHEMA.alternativeHeadline, multiple: true do |index|
    index.as :stored_searchable
  end

  property :issue, predicate: ::RDF::Vocab::Bibframe.term(:Serial), multiple: false do |index|
    index.as :stored_searchable
  end

  property :pagination, predicate: ::RDF::Vocab::BIBO.numPages, multiple: false do |index|
    index.as :stored_searchable
  end

  property :article_num, predicate: ::RDF::Vocab::BIBO.number, multiple: false do |index|
    index.as :stored_searchable
  end

  property :place_of_publication, predicate: ::RDF::Vocab::BF2.term(:Place) do |index|
    index.as :stored_searchable, :facetable
  end

  property :isbn, predicate: ::RDF::Vocab::BIBO.isbn, multiple: false do |index|
    index.as :stored_searchable
  end

  property :issn, predicate: ::RDF::Vocab::BIBO.issn, multiple: false do |index|
    index.as :stored_searchable
  end

  property :eissn, predicate: ::RDF::Vocab::BIBO.eissn, multiple: false do |index|
    index.as :stored_searchable
  end

  property :refereed, predicate: ::RDF::Vocab::BIBO.term("status/peerReviewed"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :series_name, predicate: ::RDF::Vocab::BF2.subseriesOf do |index|
    index.as :stored_searchable, :facetable
  end

  property :book_title, predicate: ::RDF::Vocab::BIBO.term(:Proceedings), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :editor, predicate: ::RDF::Vocab::SCHEMA.Person do |index|
    index.as :stored_searchable
  end

  property :edition, predicate: ::RDF::Vocab::BF2.edition, multiple: false do |index|
    index.as :stored_searchable
  end

  property :event_title, predicate: ::RDF::Vocab::BF2.term(:Event) do |index|
    index.as :stored_searchable, :facetable
  end

  property :event_location, predicate: ::RDF::Vocab::Bibframe.eventPlace do |index|
    index.as :stored_searchable
  end

  property :version_number, predicate: ::RDF::Vocab::SCHEMA.version do |index|
    index.as :stored_searchable
  end

  property :related_exhibition, predicate: ::RDF::Vocab::SCHEMA.term(:ExhibitionEvent) do |index|
    index.as :stored_searchable
  end

  property :related_exhibition_venue, predicate: ::RDF::Vocab::SCHEMA.EventVenue, multiple: true do |index|
    index.as :stored_searchable
  end

  property :related_exhibition_date, predicate: ::RDF::Vocab::SCHEMA.term(:Date) do |index|
    index.as :stored_searchable
  end

  property :media, predicate: ::RDF::Vocab::MODS.physicalForm do |index|
    index.as :stored_searchable
  end

  property :page_display_order_number, predicate: ::RDF::Vocab::SCHEMA.orderNumber, multiple: false do |index|
    index.as :stored_searchable
  end

  property :additional_links, predicate: ::RDF::Vocab::SCHEMA.significantLinks, multiple: false do |index|
    index.as :stored_searchable
  end

  property :irb_status, predicate: ::RDF::Vocab::BF2.Status, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :buy_book, predicate: ::RDF::Vocab::SCHEMA.BuyAction, multiple: false do |index|
    index.as :stored_searchable
  end

  property :is_included_in, predicate: ::RDF::Vocab::BF2.part, multiple: false do |index|
    index.as :stored_searchable
  end

  property :duration, predicate: ::RDF::Vocab::BF2.duration, multiple: true do |index|
    index.as :stored_searchable
  end

  property :reading_level, predicate: ::RDF::Vocab::SCHEMA.proficiencyLevel, multiple: false do |index|
    index.as :stored_searchable
  end

  property :challenged, predicate: ::RDF::Vocab::SCHEMA.quest, multiple: false do |index|
    index.as :stored_searchable
  end

  property :outcome, predicate: ::RDF::Vocab::SCHEMA.resultComment, multiple: false do |index|
    index.as :stored_searchable
  end

  property :participant, predicate: ::RDF::Vocab::BF2.Person, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :photo_caption, predicate: ::RDF::Vocab::SCHEMA.caption, multiple: false do |index|
    index.as :stored_searchable
  end

  property :photo_description, predicate: ::RDF::Vocab::SCHEMA.photo, multiple: false do |index|
    index.as :stored_searchable
  end

  property :degree, predicate: ::RDF::Vocab::SCHEMA.evidenceLevel, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :alt_email, predicate: ::RDF::Vocab::SCHEMA.email do |index|
    index.as :stored_searchable
  end

  property :longitude, predicate: ::RDF::Vocab::SCHEMA.longitude, multiple: false do |index|
    index.as :stored_searchable
  end

  property :latitude, predicate: ::RDF::Vocab::SCHEMA.latitude, multiple: false do |index|
    index.as :stored_searchable
  end

  property :table_of_contents, predicate: ::RDF::Vocab::Bibframe.term(:tableOfContents), multiple: false do |index|
    index.as :stored_searchable
  end

  property :alt_book_title, predicate: ::RDF::Vocab::BIBO.term(:shortTitle), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :audience, predicate: ::RDF::Vocab::BF2.IntendedAudience do |index|
    index.as :stored_searchable
  end

  property :adapted_from, predicate: ::RDF::Vocab::DC11.source, multiple: false do |index|
    index.as :stored_searchable
  end

  property :suggested_student_reviewers, predicate: ::RDF::Vocab::V.reviewer, multiple: false do |index|
    index.as :stored_searchable
  end

  property :suggested_reviewers, predicate: ::RDF::Vocab::VMD.reviewer, multiple: false do |index|
    index.as :stored_searchable
  end

  property :prerequisites, predicate: ::RDF::Vocab::CC.Requirement, multiple: false do |index|
    index.as :stored_searchable
  end

  property :advisor, predicate: ::RDF::Vocab::Bibframe.Person, multiple: false do |index|
    index.as :stored_searchable
  end

  property :current_he_institution, predicate: ::RDF::Vocab::SCHEMA.EducationalOrganization, multiple: true do |index|
    index.as :stored_searchable
  end

  property :irb_number, predicate: ::RDF::Vocab::BIBO.identifier, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :related_material, predicate: ::RDF::Vocab::BF2.term(:relatedTo), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  self.json_fields += %i[editor current_he_institution]
  self.date_fields += %i[event_date related_exhibition_date]

  self.indexer = UbiquityTemplateWorkIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
