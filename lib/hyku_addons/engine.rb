# frozen_string_literal: true
module HykuAddons
  class Engine < ::Rails::Engine
    isolate_namespace HykuAddons

    # Automount this engine
    # Only do this because this is just for us and we don't need to allow control over the mount to the application
    initializer 'hyku_additions.routes' do |app|
      app.routes.append do
        mount HykuAddons::Engine, at: '/'
      end
    end

    config.after_initialize do
      # Prepend our views so they have precedence
      ActionController::Base.prepend_view_path(paths['app/views'].existent)
      # Append our locales so they have precedence
      I18n.load_path += Dir[HykuAddons::Engine.root.join('config', 'locales', '*.{rb,yml}')]

      # Cannot do prepend here because it causes it to get loaded before AcitveRecord breaking things
      ::Account.class_eval do
        include HykuAddons::AccountBehavior

        # @return [Account] a placeholder account using the default connections configured by the application
        def self.single_tenant_default
          Account.new do |a|
            a.build_solr_endpoint
            a.build_fcrepo_endpoint
            a.build_redis_endpoint
            a.build_datacite_endpoint
          end
        end

        # Make all the account specific connections active
        def switch!
          solr_endpoint.switch!
          fcrepo_endpoint.switch!
          redis_endpoint.switch!
          datacite_endpoint.switch!
        end

        def reset!
          SolrEndpoint.reset!
          FcrepoEndpoint.reset!
          RedisEndpoint.reset!
          DataCiteEndpoint.reset!
        end
      end

      # Using a concern doesn't actually override the original method so inlining it here
      ::Proprietor::AccountsController.class_eval do
        private

          # Never trust parameters from the scary internet, only allow the allowed list through.
          def account_params
            params.require(:account).permit(:name, :cname, :title,
                                            admin_emails: [],
                                            solr_endpoint_attributes: %i[id url],
                                            fcrepo_endpoint_attributes: %i[id url base_path],
                                            datacite_endpoint_attributes: %i[mode prefix username password])
          end
      end

      ::CreateAccount.class_eval do
        def create_account_inline
          CreateAccountInlineJob.perform_now(account) && account.create_datacite_endpoint
        end
      end
    end
  end
end
