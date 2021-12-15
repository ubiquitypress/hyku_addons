# frozen_string_literal: true

## In engine development mode (ENGINE_ROOT defined) handle specific generators as app-only by setting destintation_root appropriately
# Force the destination root to be the rails application and not this engine when doing development
# See https://github.com/rails/rails/blob/fb852668dff2786a4cfb30ad923830da9eed2476/railties/lib/rails/commands/generate/generate_command.rb#L26
# and https://github.com/rails/rails/blob/9d44519afc5290eab8479db851f09653cf0a916f/railties/lib/rails/command.rb#L75-L82

if defined?(ENGINE_ROOT)
  APP_GENERATORS = [
    'HykuAddons::InstallGenerator',
    'Hyrax::DOI::InstallGenerator',
    'Hyrax::DOI::AddToWorkTypeGenerator',
    'Hyrax::Hirmeos::InstallGenerator',
    'Hyrax::Orcid::InstallGenerator'
  ].freeze

  Rails::Generators::Base.class_eval do
    def initialize(args, options, config)
      config[:destination_root] = Pathname.new(File.expand_path("../..", APP_PATH)) if self.class.name.in?(APP_GENERATORS)

      super
    end
  end
end

