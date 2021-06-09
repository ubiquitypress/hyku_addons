module HykuAddons
  module Admin
    module Ubiquitous
      class ContainersController < ::AdminController
        before_action :load_container, only: [:edit, :update, :destroy]
        helper 'hyku_addons/admin/ubiquitous/containers'

        def index
          @containers = collection
        end

        def new
          @container = collection.build
        end

        def edit
        end

        def create
          @container = collection.build(permitted_params[:container])
          if @container.save
            redirect_to [:admin, :ubiquitous, :containers], notice: t('.success')
          else
            flash.now[:error] =  t('.failure')
            render 'new'
          end
        end

        def update
          if @container.update_attributes(permitted_params[:container])
            redirect_to [:admin, :ubiquitous, :containers], notice: t('.success')
          else
            flash.now[:error] =  t('.failure')
            render 'edit'
          end
        end

        def destroy
          if @container.destroy
            redirect_to [:admin, :ubiquitous, :containers], notice: t('.success')
          else
            redirect_to [:admin, :ubiquitous, :containers], error: t('.failure')
          end
        end

        private

        def load_container
          @container = collection.find(params[:id])
        end

        def collection
          HykuAddons::Ubiquitous::Container.all
        end

        def permitted_params
          params.permit(container: [:name, :content_id, :custom_title, :custom_description, :style])
        end
      end
    end
  end
end