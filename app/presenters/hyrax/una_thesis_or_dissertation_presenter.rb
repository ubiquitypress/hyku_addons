# frozen_string_literal: true
module Hyrax
  class UnaThesisOrDissertationPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      [:title, :resource_type, :creator, :alt_email, :abstract, :keyword, :subject,
       :degree, :qualification_level, :qualification_name, :qualification_grantor,
       :advisor, :committee_member, :org_unit, :date_published, :related_identifier,
       :additional_links, :related_material, :related_url, :place_of_publication,
       :citation, :license, :rights_holder, :rights_statement, :rights_statement_text,
       :language, :location, :longitude, :latitude, :georeferenced, :add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
