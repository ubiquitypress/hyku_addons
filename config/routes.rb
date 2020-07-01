HykuAddons::Engine.routes.draw do
  post '/external_services/generate_doi', to: '/ubiquity/external_services#generate_doi', as: 'external_services_generate_doi'
end
