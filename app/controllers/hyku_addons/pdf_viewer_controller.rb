# frozen_string_literal: true

module HykuAddons
  class PdfViewerController < ApplicationController
    require 'open-uri'
    # before_action :authenticate_user!
    # load_and_authorize_resource class: ::FileSet

    def pdf
      render 'pdf_viewer/viewer', layout: 'hyku_addons/pdf_viewer'
    end
  end
end