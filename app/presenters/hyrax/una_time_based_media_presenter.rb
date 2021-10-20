# frozen_string_literal: true
module Hyrax
  class UnaTimeBasedMediaPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title resource_type creator alt_email abstract keyword subject
         org_unit date_published related_identifier additional_links related_material
         related_url event_title event_location event_date related_exhibition
         related_exhibition_venue related_exhibition_date license rights_holder
         rights_statement rights_statement_text contributor duration
         language location longitude latitude georeferenced time irb_number
         irb_status add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
