# frozen_string_literal: true
module HykuAddons
  class ImporterValidationsController < ::AdminController
    before_action :load_importer

    def show
      respond_to do |format|
        format.csv do
          send_data(HykuAddons::ImporterValidationReportService.new(@importer, params[:field]).perform,
                    type: 'text/csv; charset=utf-8; header=present',
                    disposition: 'attachment; filename=validation.csv')
        end
      end
    end

    private

      def load_importer
        @importer = Bulkrax::Importer.find(params[:id])
      end
  end
end
