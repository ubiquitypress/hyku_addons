# frozen_string_literal: true
module HykuAddons
  module CreatorFieldHelper
    def add_pacific_creator_personal_fields(array)
      array.insert(1, field_type: :text, field_slug: :creator_middle_name)
      array.insert(3, field_type: :text, field_slug: :creator_suffix)
      array.insert(4, field_type: :text, field_slug: :creator_institution, field_args: { data: { required: true } })
      array
    end
  end
end
