# frozen_string_literal: true

module HykuAddons
  module CreatorFieldHelper
    def add_pacific_creator_personal_fields(array)
      array[4] = { field_type: :text, field_slug: :creator_institution, field_args: { data: { required: true } } }
      array
    end

    def add_redlands_creator_personal_fields(array, service_options)
      array.delete_at(7) # removes institutional relationship from Redlands worktype
      array[1] = { field_type: :text, field_slug: :creator_given_name }
      array.insert(4, field_type: :select, field_slug: :creator_role, select_options: service_options, field_args: { cloneable: true, include_blank: "Please Select..." })
      array[5] = { field_type: :text, field_slug: :creator_institution, field_args: { cloneable: true } }
      array
    end

    def add_anschutz_creator_personal_fields(array, service_options)
      array.delete_at(7) # removes institutional relationship from Anschutz worktype
      array[1] = { field_type: :text, field_slug: :creator_given_name }
      array.insert(4, field_type: :select, field_slug: :creator_role, select_options: service_options, field_args: { cloneable: true, include_blank: "Please Select..." })
      array[5] = { field_type: :text, field_slug: :creator_institution, field_args: { cloneable: true } }
      array
    end

    def remove_redlands_creator_organisational_fields(array)
      array.delete_at(3) # removes wikidata from Redlands worktype
      array.delete_at(2) # removes grid from Redlands worktype
      array
    end

    def add_denver_creator_personal_fields(array, service_options)
      array.delete_at(7) # removes institutional relationship from Denver worktype
      array.append(field_type: :select, field_slug: :creator_role, select_options: service_options, field_args: { include_blank: "Please Select..." })
      array
    end

    def add_denver_creator_organisational_fields(array, service_options)
      array.append(field_type: :select, field_slug: :creator_role, select_options: service_options, field_args: { include_blank: "Please Select..." })
      array
    end

    def add_una_creator_personal_fields(array, service_options)
      array[1] = { field_type: :text, field_slug: :creator_given_name }
      array.append(field_type: :select, field_slug: :creator_role, select_options: service_options, field_args: { include_blank: "Please Select..." })
      array
    end

    def add_una_creator_organisational_fields(array, service_options)
      array.append(field_type: :select, field_slug: :creator_role, select_options: service_options, field_args: { include_blank: "Please Select..." })
      array
    end

    def add_uva_creator_personal_fields(array)
      array.delete_at(7) # removes institutional relationship from UVA worktype
      array.insert(0, field_type: :text, field_slug: :creator_computing_id)
      array.insert(5, field_type: :text, field_slug: :creator_department)
      array
    end
  end
end
