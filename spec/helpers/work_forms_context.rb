# frozen_string_literal: true
RSpec.shared_context 'work forms context' do
  let(:work) { described_class.model_class.new }
  let(:form) { described_class.new(work, nil, nil) }

  def check_attribute_group_presence(group, attrs)
    attrs.each do |attr|
      # Making them arrays to test array type fields easily
      expect(Array.wrap(model_attributes[group][attr])).to eq [attr.to_s]
    end
  end

  def check_common_fields_presence
    fields = %w[title alternative_name project_name institution abstract official_link language license
                rights_statement rights_holder doi keywords dewey library_of_congress_classification
                add_info]

    fields.each do |attr|
      expect(model_attributes[attr]).to eq attr
    end

    check_attribute_group_presence(:creator, [:creator_organization_name, :creator_given_name, :creator_family_name,
                                              :creator_name_type, :creator_orcid, :creator_isni, :creator_ror,
                                              :creator_grid, :creator_wikidata, :creator_institutional_relationship])
    check_attribute_group_presence(:contributor, [:contributor_organization_name, :contributor_given_name,
                                                  :contributor_family_name, :contributor_name_type, :contributor_orcid,
                                                  :contributor_isni, :contributor_ror, :contributor_grid,
                                                  :contributor_wikidata, :contributor_type,
                                                  :contributor_institutional_relationship])
    check_attribute_group_presence(:date_published, [:date_published_year, :date_published_month, :date_published_day])
    check_attribute_group_presence(:date_accepted, [:date_accepted_year, :date_accepted_month, :date_accepted_day])
    check_attribute_group_presence(:date_submitted, [:date_submitted_year, :date_submitted_month, :date_submitted_day])
    check_attribute_group_presence(:funder, [:funder_name, :funder_doi, :funder_isni, :funder_ror, :funder_award])
    check_attribute_group_presence(:alternate_identifier, [:alternate_identifier, :alternate_identifier_type])
    check_attribute_group_presence(:related_identifier, [:related_identifier, :related_identifier_type, :relation_type])
  end

  def common_params
    {
      title: 'title',
      resource_type: described_class.model_class.to_s,
      alternative_name: 'alternative_name',
      institution: 'institution',
      project_name: 'project_name',
      abstract: 'abstract',
      official_link: 'official_link',
      language: 'language',
      license: 'license',
      rights_statement: 'rights_statement',
      rights_holder: 'rights_holder',
      doi: 'doi',
      keywords: 'keywords',
      dewey: 'dewey',
      library_of_congress_classification: 'library_of_congress_classification',
      add_info: 'add_info'
    }.merge(creator_params, contributor_params, date_published_params, funder_params, date_accepted_params,
            date_submitted_params, related_identifier_params, alternate_identifier_params)
  end

  def creator_params
    {
      creator: {
        creator_organization_name: 'creator_organization_name',
        creator_given_name: 'creator_given_name',
        creator_name_type: 'creator_name_type',
        creator_family_name: 'creator_family_name',
        creator_orcid: 'creator_orcid',
        creator_isni: 'creator_isni',
        creator_ror: 'creator_ror',
        creator_grid: 'creator_grid',
        creator_wikidata: 'creator_wikidata',
        creator_institutional_relationship: ['creator_institutional_relationship']
      }
    }
  end

  def contributor_params
    {
      contributor: {
        contributor_organization_name: 'contributor_organization_name',
        contributor_given_name: 'contributor_given_name',
        contributor_name_type: 'contributor_name_type',
        contributor_family_name: 'contributor_family_name',
        contributor_orcid: 'contributor_orcid',
        contributor_isni: 'contributor_isni',
        contributor_ror: 'contributor_ror',
        contributor_grid: 'contributor_grid',
        contributor_wikidata: 'contributor_wikidata',
        contributor_type: 'contributor_type',
        contributor_institutional_relationship: ['contributor_institutional_relationship']
      }
    }
  end

  def date_accepted_params
    {
      date_accepted: {
        date_accepted_year: 'date_accepted_year',
        date_accepted_month: 'date_accepted_month',
        date_accepted_day: 'date_accepted_day'
      }
    }
  end

  def date_published_params
    {
      date_published: {
        date_published_year: 'date_published_year',
        date_published_month: 'date_published_month',
        date_published_day: 'date_published_day'
      }
    }
  end

  def date_submitted_params
    {
      date_submitted: {
        date_submitted_year: 'date_submitted_year',
        date_submitted_month: 'date_submitted_month',
        date_submitted_day: 'date_submitted_day'
      }
    }
  end

  def editor_params
    {
      editor: {
        editor_isni: 'editor_isni',
        editor_orcid: 'editor_orcid',
        editor_family_name: 'editor_family_name',
        editor_given_name: 'editor_given_name',
        editor_organisational_name: 'editor_organisational_name',
        editor_institutional_relationship: 'editor_institutional_relationship'
      }
    }
  end

  def funder_params
    {
      funder: {
        funder_isni: 'funder_isni',
        funder_name: 'funder_name',
        funder_doi: 'funder_doi',
        funder_ror: 'funder_ror',
        funder_award: ['funder_award']
      }
    }
  end

  def alternate_identifier_params
    {
      alternate_identifier: {
        alternate_identifier: 'alternate_identifier',
        alternate_identifier_type: 'alternate_identifier_type'
      }
    }
  end

  def related_identifier_params
    {
      related_identifier: {
        related_identifier: 'related_identifier',
        related_identifier_type: 'related_identifier_type',
        relation_type: 'relation_type'
      }
    }
  end

  def event_params
    {
      event_title: 'event_title',
      event_location: 'event_location'
    }
  end

  def event_date_params
    {
      event_date: {
        event_date_year: 'event_date_year',
        event_date_month: 'event_date_month',
        event_date_day: 'event_date_day'
      }
    }
  end

  describe 'add_terms' do
    context 'with no previous terms' do
      around do |example|
        # Reset the class variable to avoid side effects in subsequent tests
        @terms = described_class.terms
        example.run
        described_class.terms = @terms
      end

      it "adds the terms passed as params" do
        described_class.add_terms :pagination
        expect(form.terms).to include(:pagination)
      end

      it "doesnt add terms if not included in the list of valid terms" do
        described_class.add_terms :foo
        expect(form.terms).not_to include(:foo)
      end

      it "respects the correct order of the fields" do
        described_class.add_terms :title
        expect(form.terms.last).not_to eq :title
      end

      it "removes duplicates" do
        described_class.add_terms :title
        expect(form.terms).to include(:title).once
      end
    end
  end
end
