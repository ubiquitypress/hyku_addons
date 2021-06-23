# frozen_string_literal: true

module HykuAddons
  module ContributorFieldHelper

    def add_redlands_contributor_personal_fields(array, service_options)
      array.delete_at(6) # removes institutional relationship from Redlands worktype
      array[1] = { field_type: :text, field_slug: :contributor_given_name }
      array.insert(4, field_type: :select, field_slug: :contributor_role, select_options: service_options, field_args: { cloneable: true, include_blank: "Please Select..." })
      array[5] = { field_type: :text, field_slug: :contributor_institution, field_args: { cloneable: true } }
      array
    end

    def add_anschutz_contributor_personal_fields(array, service_options)
      array.delete_at(6) # removes institutional relationship from Anschutz worktype
      array[1] = { field_type: :text, field_slug: :contributor_given_name }
      array.insert(4, field_type: :select, field_slug: :contributor_role, select_options: service_options, field_args: { cloneable: true, include_blank: "Please Select..." })
      array[5] = { field_type: :text, field_slug: :contributor_institution, field_args: { cloneable: true } }
      array
    end

    def remove_redlands_contributor_organisational_fields(array)
      array.delete_at(4) # removes isni from Redlands worktype
      array.delete_at(3) # removes wikidata from Redlands worktype
      array.delete_at(2) # removes grid from Redlands worktype
      array
    end

    def remove_anschutz_contributor_organisational_fields(array)
      array.delete_at(4) # Removes isni from Anschutz worktype
      array
    end

    def add_uva_contributor_personal_fields(array)
      array.delete_at(6) # removes institutional relationship from UVA worktype
      array.insert(0, field_type: :text, field_slug: :contributor_computing_id)
      array.insert(5, field_type: :text, field_slug: :contributor_department)
      array
    end
  end
end
