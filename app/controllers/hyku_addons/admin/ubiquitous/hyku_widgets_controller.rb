module HykuAddons
  module Admin
    module Ubiquitous
      class HykuWidgetsController < ::AdminController
        before_action :load_parent_page
        before_action :load_hyku_widget, except: [:new, :create]

        def new
          @hyku_widget = collection.build
        end

        def edit
        end

        def create
          @hyku_widget = collection.build(permitted_params[:hyku_widget])
          if @hyku_widget.save
            redirect_to [:edit, :admin, @page], notice: t('.success')
          else
            flash.now[:error] =  t('.failure')
            render 'new'
          end
        end

        def update
          if @hyku_widget.update_attributes(permitted_params[:hyku_widget])
            redirect_to [:edit, :admin, @page], notice: t('.success')
          else
            flash.now[:error] =  t('.failure')
            render 'edit'
          end
        end

        def destroy
          if @hyku_widget.destroy
            redirect_to [:edit, :admin, @page], notice: t('.success')
          else
            redirect_to [:edit, :admin, @page], error: t('.failure')
          end
        end

        private

        def load_parent_page
          @page = HykuAddons::Ubiquitous::Page.find(params[:page_id])
        end

        def collection
          @page.hyku_widgets.all
        end

        def load_hyku_widget
          @hyku_widget = collection.find(params[:id])
        end

        def permitted_params
          params.permit(hyku_widget: [:name, :container_id, :position, :height, :width])
        end
      end
    end
  end
end