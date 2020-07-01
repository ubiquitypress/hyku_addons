RSpec.describe Ubiquity::ExternalServicesController, type: :controller do
  routes { HykuAddons::Engine.routes }

  it 'works' do
    post :generate_doi
    expect(response).to have_http_status(:ok)
    expect(response.content_type).to eq "application/json"
    expect(response.body).to be_present
  end
end
