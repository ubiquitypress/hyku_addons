# frozen_string_literal: true

require "spec_helper"

RSpec.describe CatalogController, type: :request, clean: true, multitenant: true do
  let(:user) { create(:user, email: "test_user@repo-sample.edu") }
  let(:work) { build(:work, title: ["welcome test"], id: SecureRandom.uuid, user: user) }

  let(:hyku_sample_work) { build(:work, title: ["sample test"], id: SecureRandom.uuid, user: user) }
  let(:sample_solr_connection) { RSolr.connect url: "http://solr:8983/solr/hydra-sample" }

  let(:cross_search_solr) { create(:solr_endpoint, url: "http://solr:8983/solr/hydra-cross-search-tenant") }
  let!(:cross_search_tenant_account) do
    create(:account,
           name: "cross_serch",
           solr_endpoint: cross_search_solr,
           fcrepo_endpoint: nil)
  end

  before do
    WebMock.disable!
    allow(AccountElevator).to receive(:switch!).with(cross_search_tenant_account.cname).and_return("public")
    allow(Apartment::Tenant.adapter).to receive(:connect_to_new).and_return("")
    ActiveFedora::SolrService.instance.conn = sample_solr_connection
    ActiveFedora::SolrService.add(hyku_sample_work.to_solr)
    ActiveFedora::SolrService.commit

    ActiveFedora::SolrService.reset!
    ActiveFedora::SolrService.add(work.to_solr)
    ActiveFedora::SolrService.commit
  end

  after do
    WebMock.enable!

    ActiveFedora::SolrService.instance.conn = sample_solr_connection
    ActiveFedora::SolrService.delete(hyku_sample_work.id)
    ActiveFedora::SolrService.commit

    ActiveFedora::SolrService.reset!
    ActiveFedora::SolrService.delete(work.id)
    ActiveFedora::SolrService.commit
  end

  describe "Search page can load when ltu_time_based_media work exists" do
    let!(:work) { LtuTimeBasedMedia.create(title: ["Test"], visibility: "open") }
    let!(:account) { create(:account, name: "normal search") }

    before do
      host! account.cname
    end

    it "can load search page do" do
      get "/catalog?locale=en&search_field=all_fields&q="
      expect(response.status).to eq(200)
    end

    it "load search page does not throw error" do
      expect { get "/catalog?locale=en&search_field=all_fields&q=" }.not_to raise_error(ActionView::Template::Error)
    end
  end

  describe "Cross Tenant Search" do
    let(:cross_tenant_solr_options) do
      {
        "read_timeout" => 120,
        "open_timeout" => 120,
        "url" => "http://solr:8983/solr/hydra-cross-search-tenant",
        "adapter" => "solr"
      }
    end

    let(:black_light_config) { Blacklight::Configuration.new(connection_config: cross_tenant_solr_options) }

    let(:blacklight_solr_repository) { instance_double(Blacklight::Solr::Repository) }

    before do
      host! cross_search_tenant_account.cname
    end

    context "can fetch data from other tenants" do
      xit "cross-search-tenant can fetch all record in child tenants" do
        connection = RSolr.connect(url: "http://solr:8983/solr/hydra-cross-search-tenant")
        allow(blacklight_solr_repository).to receive(:build_connection).and_return(connection)
        allow(CatalogController).to receive(:blacklight_config).and_return(black_light_config)

        get search_catalog_url, params: { locale: "en", q: "test" }
        expect(response.status).to eq(200)
      end
    end
  end
end
