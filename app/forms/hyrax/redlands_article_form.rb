# Generated via
#  `rails generate hyrax:work RedlandsArticle`
module Hyrax
  # Generated form for RedlandsArticle
  class RedlandsArticleForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::RedlandsArticle
    add_terms %i[title alt_title resource_type creator contributor alt_email abstract keyword subject
                 org_unit language license version_number date_published journal_title
                 volume issue pagination official_link related_identifier location
                 longitude latitude add_info]
    self.terms -= %i[rights_statement publisher related_url]
    self.required_fields = %i[title creator alt_email resource_type abstract keywork subject
                              org_unit language license version_number date_published journal_title]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alt_title, :alt_email, :volume, :journal_title, :org_unit, :subject, :keyword,
                             :language, :version_number, :issue, :pagination, :location, :longitude,
                             :latitude, :license]
      end
    end
  end
end
