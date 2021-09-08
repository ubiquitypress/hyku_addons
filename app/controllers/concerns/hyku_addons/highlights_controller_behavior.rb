# frozen_string_literal: true
module HykuAddons
  module HighlightsControllerBehavior
    extend ActiveSupport::Concern

    def index
      @collections = collections(rows: 6)
      @recent_documents = recent_documents(rows: 6)
      @featured_works_list = FeaturedWorkList.new.featured_works.select { |fw| current_ability.can? :read, fw.work_id }
      @featured_works = Hyrax::PresenterFactory.build_for(ids: @featured_works_list.map(&:work_id),
                                                          presenter_class: Hyrax::WorkShowPresenter,
                                                          presenter_args: current_ability)
      collection_search_builder = Hyrax::CollectionSearchBuilder.new(self).with_access(:read).rows(1_000_000)
      @collection_docs = repository.search(collection_search_builder).documents
    end
  end
end
