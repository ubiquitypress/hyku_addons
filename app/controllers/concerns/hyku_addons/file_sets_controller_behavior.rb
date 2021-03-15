module HykuAddons
  module FileSetsControllerBehavior
    extend ActiveSupport::Concern

    def download
      render json: {
        signed_url: HykuAddons::FileSignedUrlService.new(file: file_set.original_file).perform,
        file_name: file_set.title.first
      }, status: 200
    end

    def file_set
      @file_set ||= begin
        return unless file_presenter&.current_ability&.can?(:read, file_document.id)

        FileSet.find(file_document.id)
      end
    end

    def file_presenter
      @file_presenter ||= Hyrax::FileSetPresenter.new(file_document, current_ability, request)
    end

    def file_document
      @file_document ||= begin
        repository.search(Hyrax::FileSetSearchBuilder.new(self).with(params.slice(:id))).documents.first
      end
    end
  end
end
