module HykuAddons
  module FileSetsControllerBehavior
    extend ActiveSupport::Concern

    def download
      render json: {
        signed_url: HykuAddons::FileSignedUrlService.new(file: @file_set.original_file).perform,
        file_name: @file_set.title.first
      }, status: 200
    end
  end
end
