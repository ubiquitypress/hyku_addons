# frozen_string_literal: true

RSpec.describe Hyrax::Actors::FileSetActor do
  let(:user) { create(:user) }
  let(:file_path) { File.join(fixture_path, "images", "world.png") }
  let(:local_file) { File.open(file_path) }
  let(:file) { fixture_file_upload(file_path, "image/png") }
  let(:file_set) { create(:file_set, content: local_file) }
  let(:actor) { described_class.new(file_set, user) }
  let(:work) { create(:generic_work) }

  before do
    allow(actor).to receive(:acquire_lock_for).and_yield

    actor.create_metadata
    actor.create_content(file)
  end

  describe "attach_to_work" do
    before do
      allow(Hyrax.config.callback).to receive(:run).with(:after_create_fileset, file_set, user)
      allow(Hyrax.config.callback).to receive(:run).with(:task_master_after_create_fileset, file_set, user)

      actor.attach_to_work(work)
    end

    it "calls the task master callback" do
      expect(Hyrax.config.callback).to have_received(:run).with(:task_master_after_create_fileset, file_set, user)
    end
  end
end
