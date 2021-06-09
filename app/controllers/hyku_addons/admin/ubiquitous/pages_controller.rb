module HykuAddons
  module Admin
    module Ubiquitous
      class PagesController < ::AdminController
        before_action :load_page, only: [:edit, :update, :destroy]

        def index
          @pages = collection
        end

        def new
          @page = collection.build
        end

        def edit
        end

        def create
          @page = collection.build(permitted_params[:page])
          if @page.save
            redirect_to [:admin, :ubiquitous, :pages], notice: t('.success')
          else
            flash.now[:error] =  t('.failure')
            render 'new'
          end
        end

        def update
          if @page.update_attributes(permitted_params[:page])
            redirect_to [:admin, :ubiquitous, :pages], notice: t('.success')
          else
            flash.now[:error] =  t('.failure')
            render 'edit'
          end
        end

        def destroy
          if @page.destroy
            redirect_to [:admin, :ubiquitous, :pages], notice: t('.success')
          else
            redirect_to [:admin, :ubiquitous, :pages], error: t('.failure')
          end
        end

        private

        def load_page
          @page = collection.find(params[:id])
        end

        def collection
          HykuAddons::Ubiquitous::Page.all
        end

        def permitted_params
          params.permit(page: [:name, :path_matcher, :grid_columns_count, :disabled_at])
        end
      end
    end
  end
end