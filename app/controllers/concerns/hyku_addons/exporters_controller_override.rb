# frozen_string_literal: true

# Overrides to allow using HykuAddons::MultitenantExporterJob to handle the export
module HykuAddons
  module ExportersControllerOverride
    extend ActiveSupport::Concern

    included do
      class_eval do
        def create
          @exporter = Bulkrax::Exporter.new(exporter_params)
          field_mapping_params

          if @exporter.save
            if params[:commit] == 'Create and Export'
              # Use perform later for creating the export in the background
              HykuAddons::MultitenantExporterJob.perform_later(current_account.id, @exporter.id)
            end
            redirect_to bulkrax.exporters_path, notice: 'Exporter was successfully created.'
          else
            render :new
          end
        end

        def update
          field_mapping_params
          if @exporter.update(exporter_params)
            # Use perform later for creating the export in the background
            Bulkrax::MultitenantExporterJob.perform_later(current_account.id, @exporter.id) if params[:commit] == 'Update and Re-Export All Items'
            redirect_to bulkrax.exporters_path, notice: 'Exporter was successfully updated.'
          else
            render :edit
          end
        end
      end
    end
  end
end
