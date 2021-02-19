# frozen_string_literal: true
module HykuAddons
  module ContributorFieldHelper
    def add_pacific_contributor_personal_fields(array)
      array.insert(1,{ field_type: :text, field_slug: :contributor_middle_name })
      array.insert(3,{ field_type: :text, field_slug: :contributor_suffix })
      array.insert(4,{ field_type: :text, field_slug: :contributor_institution })
      array
    end
  end
end
