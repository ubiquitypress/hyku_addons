# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActionView::LookupContext do
  subject(:lookup_context) { described_class.new(view_paths, details, prefixes) }
  let(:handlers) { [:raw, :erb, :html, :builder, :ruby, :coffee, :jbuilder, :haml] }
  let(:details) { { locale: [:en], formats: [:html], variants: [], handlers: handlers } }
  let(:prefixes) { ["hyrax/dashboard/profiles", "hyrax/users", "application"] }
  let(:view_paths) { ActionController::Base.view_paths }

  context "works" do
    let(:prefixes) { ["hyrax/generic_works", "application", "hyrax/base"] }
    let(:path) { "records/edit_fields/default" }

    it "returns the hyku addons partial location" do
      location = HykuAddons::Engine.root.join("app", "views", "records", "edit_fields", "_default.html.erb").to_s
      identifier = lookup_context.find_template(path, [], true, [:f, :key], {}).identifier

      expect(identifier).to eq location
    end
  end

  context "collections" do
    let(:prefixes) { ["hyrax/dashboard/collections", "hyrax/my/collections", "hyrax/my", "application", "catalog", "hyrax/base"] }
    let(:path) { "records/edit_fields/default" }

    it "returns the hyku addons partial location" do
      location = HykuAddons::Engine.root.join("app", "views", "records", "edit_fields", "_default.html.erb").to_s
      identifier = lookup_context.find_template(path, [], true, [:f, :key], {}).identifier

      expect(identifier).to eq location
    end
  end
end
