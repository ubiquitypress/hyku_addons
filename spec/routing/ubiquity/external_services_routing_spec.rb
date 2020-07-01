RSpec.describe Ubiquity::ExternalServicesController, type: :routing do
  routes { HykuAddons::Engine.routes }
  it 'works' do
    expect(:post => "/external_services/generate_doi").to route_to("ubiquity/external_services#generate_doi")
  end
end
