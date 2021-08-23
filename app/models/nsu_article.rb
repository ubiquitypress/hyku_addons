# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work NsuArticle`
class NsuArticle < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  # Adds behaviors for hyrax-doi plugin.
  include Hyrax::DOI::DOIBehavior
  # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
  include Hyrax::DOI::DataCiteDOIBehavior
  include ::HykuAddons::WorkBase
  include ::HykuAddons::AddInfoSingular

  property :alt_email, predicate: ::RDF::Vocab::SCHEMA.email, multiple: false do |index|
    index.as :stored_searchable
  end

  property :degree, predicate: ::RDF::Vocab::SCHEMA.evidenceLevel, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :qualification_name, predicate: ::RDF::Vocab::SCHEMA.qualifications, multiple: false do |index|
    index.as :stored_searchable
  end

  property :qualification_level, predicate: ::RDF::Vocab::BF2.degree, multiple: false do |index|
    index.as :stored_searchable
  end

  property :advisor, predicate: ::RDF::Vocab::Bibframe.Person, multiple: true do |index|
    index.as :stored_searchable
  end
  
  property :volume, predicate: ::RDF::Vocab::BIBO.volume do |index|
    index.as :stored_searchable
  end

  property :issue, predicate: ::RDF::Vocab::Bibframe.term(:Serial), multiple: false do |index|
    index.as :stored_searchable
  end

  property :pagination, predicate: ::RDF::Vocab::BIBO.numPages, multiple: false do |index|
    index.as :stored_searchable
  end

  property :issn, predicate: ::RDF::Vocab::BIBO.issn, multiple: false do |index|
    index.as :stored_searchable
  end

  property :refereed, predicate: ::RDF::Vocab::BIBO.term("status/peerReviewed"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :irb_status, predicate: ::RDF::Vocab::BF2.Status, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :irb_number, predicate: ::RDF::Vocab::BIBO.identifier, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :isbn, predicate: ::RDF::Vocab::BIBO.isbn, multiple: false do |index|
    index.as :stored_searchable
  end

  property :book_title, predicate: ::RDF::Vocab::BIBO.term(:Proceedings), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :alt_book_title, predicate: ::RDF::Vocab::BIBO.term(:shortTitle), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :edition, predicate: ::RDF::Vocab::BF2.edition, multiple: false do |index|
    index.as :stored_searchable
  end

  property :version_number, predicate: ::RDF::Vocab::SCHEMA.version do |index|
    index.as :stored_searchable
  end

  property :mesh, predicate: ::RDF::Vocab::DC.term(:MESH) do |index|
    index.as :stored_searchable
  end

  property :adapted_from, predicate: ::RDF::Vocab::DC11.source, multiple: false do |index|
    index.as :stored_searchable
  end

  property :series_name, predicate: ::RDF::Vocab::BF2.subseriesOf do |index|
    index.as :stored_searchable, :facetable
  end

  property :eissn, predicate: ::RDF::Vocab::BIBO.eissn, multiple: false do |index|
    index.as :stored_searchable
  end

  property :place_of_publication, predicate: ::RDF::Vocab::BF2.term(:Place) do |index|
    index.as :stored_searchable, :facetable
  end

  property :funder, predicate: ::RDF::Vocab::MARCRelators.fnd do |index|
    index.as :stored_searchable
  end

  property :editor, predicate: ::RDF::Vocab::SCHEMA.Person do |index|
    index.as :stored_searchable
  end

  property :date_accepted, predicate: ::RDF::Vocab::DC.dateAccepted, multiple: false do |index|
    index.as :stored_searchable
  end

  property :date_submitted, predicate: ::RDF::Vocab::Bibframe.originDate, multiple: false do |index|
    index.as :stored_searchable
  end

  property :table_of_contents, predicate: ::RDF::Vocab::Bibframe.term(:tableOfContents), multiple: false do |index|
    index.as :stored_searchable
  end

  property :references, predicate: ::RDF::Vocab::DC.references do |index|
    index.as :stored_searchable
  end

  property :medium, predicate: ::RDF::Vocab::DC.medium do |index|
    index.as :stored_searchable
  end

  property :extent, predicate: ::RDF::Vocab::DC.extent, multiple: false do |index|
    index.as :stored_searchable
  end

  property :audience, predicate: ::RDF::Vocab::BF2.IntendedAudience do |index|
    index.as :stored_searchable, :facetable
  end

  property :time, predicate: ::RDF::Vocab::DC.temporal do |index|
    index.as :stored_searchable
  end

  property :suggested_student_reviewers, predicate: ::RDF::Vocab::V.reviewer, multiple: false do |index|
    index.as :stored_searchable
  end

  property :suggested_reviewers, predicate: ::RDF::Vocab::VMD.reviewer, multiple: false do |index|
    index.as :stored_searchable
  end

  property :committee_member, predicate: ::RDF::Vocab::AS.term(:Person) do |index|
    index.as :stored_searchable
  end

  property :journal_title, predicate: ::RDF::Vocab::BIBO.Journal, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :alternative_journal_title, predicate: ::RDF::Vocab::SCHEMA.alternativeHeadline, multiple: true do |index|
    index.as :stored_searchable
  end

  property :journal_frequency, predicate: ::RDF::Vocab::DC.term(:Frequency), multiple: false do |index|
    index.as :stored_searchable
  end

  self.json_fields += %i[editor]
  self.indexer = NsuArticleIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
