# frozen_string_literal: true
module HykuAddons
  module ContributorFieldHelper
    def add_pacific_contributor_personal_fields(array)
      array.insert(1, field_type: :text, field_slug: :contributor_middle_name)
      array.insert(3, field_type: :text, field_slug: :contributor_suffix)
      array.insert(4, field_type: :text, field_slug: :contributor_institution)
      array
    end

    def add_uva_contributor_personal_fields(array)
      array.delete_at(3) # removes institutional relationship from UVA worktype
      array.insert(0, field_type: :text, field_slug: :contributor_computing_id)
      array.insert(4, field_type: :text, field_slug: :contributor_institution)
      array.insert(5, field_type: :text, field_slug: :contributor_department)
    end
  end
end
