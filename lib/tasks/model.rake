# frozen_string_literal: true

require HykuAddons::Engine.root.join("lib/hyrax/schema_generator.rb")

namespace :hyku_addons do
  namespace :model do
    # Usage: docker-compose exec web bundle exec rails app:hyku_addons:model:generate_schema[ubiquity_template_work]
    task :generate_schema, [:model_name] => [:environment] do |_t, args|
      yaml = Hyrax::SchemaGenerator.new(args[:model_name]).perform

      File.write(HykuAddons::Engine.root.join("config", "metadata", "#{args[:model_name]}.yaml"), yaml)
    end
  end
end
