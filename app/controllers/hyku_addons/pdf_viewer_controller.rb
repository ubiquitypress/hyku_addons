# frozen_string_literal: true

module HykuAddons
  class PdfViewerController < ApplicationController
    def pdf
      render 'pdf_viewer/viewer', layout: 'hyku_addons/pdf_viewer'
    end
  end
end
