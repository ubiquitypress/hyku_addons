# frozen_string_literal: true
module HykuAddons
  module SolrDocumentWrapperExtensions
    extend ActiveSupport::Concern

    def find(selector, options = {})
      return next_set(options[:resumption_token]) if options[:resumption_token]

      if selector == :all
        response = @controller.repository.search(conditions(options))

        if limit && response.total > limit
          return select_partial(BlacklightOaiProvider::ResumptionToken.new(options.merge(last: 0), nil, response.total))
        end
        response.documents
      else
        query = @controller.search_builder.where("id:#{selector}").query
        @controller.repository.search(query).documents.first
      end
    end
  end
end
