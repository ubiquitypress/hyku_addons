# frozen_string_literal: true

module HykuAddons
  class AddCnameToExistingWorksJob < ApplicationJob
    def perform(array_of_cname)
      array_of_cname.each do |cname|
        fetch_work_save_cname(cname)
      end
    end

    private

      def fetch_work_save_cname(cname)
        AccountElevator.switch!("#{cname}")
        available_works = Site.first.available_works | ['Collection']
        available_works.each do |model|
          model.constantize.find_each(work_tenant_cname: nil) do |model_instance|
            if model_instance.work_tenant_cname.blank?
              puts model_instance.inspect
              puts model_instance.class
              model_instance.update(work_tenant_cname: cname)
              sleep 2
            end
          end
        end
      end
  end
end
