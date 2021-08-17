# frozen_string_literal: true

# Overrides Hyku API facet method to allow Languages to be returned as terms not id's
module HykuAddons
  module SearchControllerBehavior
    extend ActiveSupport::Concern

    def facet
      if params[:id] == 'all'
        # Set facet.limit to -1 for all facets when sending solr request so all facet values get returned
        solr_params = search_builder.with(params).to_h
        solr_params.each_key { |k| solr_params[k] = -1 if k.match?(/^f\..+\.limit$/) }
        @response = repository.search(solr_params)
        facets = @response.aggregations.transform_values { |v| hash_of_terms_ordered_by_hits(v.items) }

        language_service = HykuAddons::LanguageService.new
        facets['language_sim'] = facets['language_sim'].map do |id, count|
          [language_service.label(id), count]
        rescue KeyError
          nil
        end.compact.to_h

        render json: facets
      else
        super
        render json: hash_of_terms_ordered_by_hits(@display_facet.items[facet_range])
      end
    end

    # THIS NEEDS TO BE REMOVED ONCE CASHING IS SOLVED AND HYKU API TRACKS MAIN BRANCH
    private

      def hash_of_terms_ordered_by_hits(items)
        Hash[items.pluck(:value, :hits).sort_by(&:second).reverse]
      end
  end
end
