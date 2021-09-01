
module HykuAddons
  module ActiveFedora
    module SolrServiceExtensions
      extend ActiveSupport::Concern

      included do

        # Automatically handles the pagination of the SolrService object in case we need to make huge queries
        # Allows passing a block of code to to execute something against each hit, in a similar way of Rails'
        # find_each
        # TODO: Make it return an [Enumerable] as find_each does to get all the extra nice functionality of it.
        def self.find_each(query, args = {})
          args = args.merge(q: query, qt: 'standard')
          returning_items = []
          page = 0
          parsed_items_count = 0

          loop do
            args.merge!(start: page)
            solr_response = ::ActiveFedora::SolrService.instance.conn.get(select_path, params: args)
            total_hits = solr_response['response']['numFound']&.to_i || 0
            break if total_hits.zero?

            puts solr_response
            docs = solr_response["response"]["docs"]
            returning_items += docs

            if block_given?
              docs.each do |solr_document|
                yield(solr_document)
              end
            end

            parsed_items_count += solr_response["response"]["docs"].count
            break if parsed_items_count >= total_hits
            page = page.next
          end
          returning_items
        end
      end
    end
  end
end
