# frozen_string_literal: true
module HykuAddons
  module ImporterControllerBehavior
    extend ActiveSupport::Concern

    included do
      class_eval do
        def show
          if api_request?
            json_response('show')
          else
            add_importer_breadcrumbs
            add_breadcrumb @importer.name

            @work_entries = @importer.entries.where(type: @importer.parser.entry_class.to_s).page(params[:work_entries_page]).per(30)
            @collection_entries = @importer.entries.where(type: @importer.parser.collection_entry_class.to_s).page(params[:collections_entries_page]).per(30)
            respond_to do |format|
              format.html
              format.csv do
                send_data(HykuAddons::Validations::ImporterReportService.new(@importer).perform(self),
                          type: 'text/csv; charset=utf-8; header=present',
                          disposition: 'attachment; filename=importer-report.csv')
              end
            end
          end
        end
      end
    end
  end
end
