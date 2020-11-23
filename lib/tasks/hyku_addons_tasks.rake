# frozen_string_literal: true
namespace :allinson_flex do
  desc "Install a profile from file and generate work classes"
  task :install_profile, [:profile_path] => [:environment] do |t, args|
    AllinsonFlex::Importer.load_profile_from_path(path: args[:profile_path])
    sh 'rails generate allinson_flex:works'
  end
end
