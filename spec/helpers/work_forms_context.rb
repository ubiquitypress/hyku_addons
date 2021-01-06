RSpec.shared_context 'work forms context' do

  let(:work) { GenericWork.new }
  let(:form) { described_class.new(work, nil, nil) }

  def check_attribute_group_presence(group, attrs)
    attrs.each do |attr|
      # Making them arrays to test array type fields easily
      expect(Array.wrap(model_attributes[group][attr])).to eq [attr.to_s]
    end
  end

  def creator_fields
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
            creator_institutional_relationship: ['creator_institutional_relationship'],
        }
    }
  end

  def contributor_fields
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
            contributor_institutional_relationship: ['contributor_institutional_relationship'],
        }
    }
  end

  def date_accepted_fields
    {
        date_accepted: {
            date_accepted_year: 'date_accepted_year',
            date_accepted_month: 'date_accepted_month',
            date_accepted_day: 'date_accepted_day',
        }
    }
  end

  def date_published_fields
    {
        date_published: {
            date_published_year: 'date_published_year',
            date_published_month: 'date_published_month',
            date_published_day: 'date_published_day',
        }
    }
  end

  def date_submitted_fields
    {
        date_submitted: {
            date_submitted_year: 'date_submitted_year',
            date_submitted_month: 'date_submitted_month',
            date_submitted_day: 'date_submitted_day',
        }
    }
  end

  def editor_fields
    {
        editor: {
            editor_isni: 'editor_isni',
            editor_orcid: 'editor_orcid',
            editor_family_name: 'editor_family_name',
            editor_given_name: 'editor_given_name',
            editor_organisational_name: 'editor_organisational_name',
            editor_institutional_relationship: 'editor_institutional_relationship',
        }
    }
  end

  def funder_fields
    {
        funder: {
            funder_isni: 'funder_isni',
            funder_name: 'funder_name',
            funder_doi: 'funder_doi',
            funder_ror: 'funder_ror',
            funder_award: ['funder_award'],
        }
    }
  end

  def alternate_identifier_fields
    {
        alternate_identifier: {
            alternate_identifier: 'alternate_identifier',
            alternate_identifier_type: 'alternate_identifier_type',
        }
    }
  end


  def related_identifier_fields
    {
        related_identifier: {
            related_identifier: 'related_identifier',
            related_identifier_type: 'related_identifier_type',
            relation_type: 'relation_type',
        }
    }
  end

end
