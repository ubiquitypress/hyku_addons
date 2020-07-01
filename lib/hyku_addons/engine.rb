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
    end
  end
end
