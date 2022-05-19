# frozen_string_literal: true
require "rails_helper"

RSpec.describe HykuAddons::WorkflowBehavior do
  let(:work) { create(:work) }
  let(:solr_hash) { work.to_solr }
  let(:user) { create(:user) }
  let(:protocol) { "http" }
  let(:work_type) { work.model_name.plural }
  let(:host) { "repo.hyku.docker" }

  let(:gid) { "gid://hyku/#{work.class}/#{work.id}" }
  let(:entity) { instance_double(Sipity::Entity, proxy_for_global_id: gid, proxy_for: work, workflow_id: nil, workflow_state: nil) }
  let(:url) { "#{protocol}://#{host}/concern/#{work_type}/#{work.id}" }

  let(:pending_review_notification) { Hyrax::Workflow::PendingReviewNotification.new(entity, "", user, {}) }

  before do
    allow(Site.instance.account).to receive(:cname) { host }
  end

  describe "workflow notification" do
    it "email links should have the correct url to work show page" do
      expect(pending_review_notification.send(:document_path)).to eq url
    end
  end
end
