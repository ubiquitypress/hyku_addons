# frozen_string_literal: true

require "rails_helper"

# ActionView::LookupContext - https://github.com/rails/rails/blob/5-2-stable/actionview/lib/action_view/lookup_context.rb#L222
#
# details = @lookup_context.instance_variable_get("@details")
# {:locale: [:en], :formats: [:html], :variants: [], :handlers: [:raw, :erb, :html, :builder, :ruby, :coffee, :jbuilder, :haml]}
# prefixes = @lookup_context.instance_variable_get("@prefixes")
# ["hyrax/generic_works", "application", "hyrax/base"]
# ActionView::LookupContext.new(ActionController::Base.view_paths, details, prefixes)

# puts lookup_context.method(:find_template).source
# def find(name, prefixes = [], partial = false, keys = [], options = {})
#   @view_paths.find(*args_for_lookup(name, prefixes, partial, keys, options))
# end
#
# /usr/local/rvm/gems/ruby-2.7.4/gems/actionview-5.2.6/lib/action_view/renderer/partial_renderer.rb
# def find_template(path, locals)
#   prefixes = path.include?(?/) ? [] : @lookup_context.prefixes
#   @lookup_context.find_template(path, prefixes, true, locals, @details)
# end
RSpec.describe "Hyku Addons View Order" do
  let(:handlers) { [:raw, :erb, :html, :builder, :ruby, :coffee, :jbuilder, :haml] }
  let(:details) { { locale: [:en], formats: [:html], variants: [], handlers: handlers } }
  let(:prefixes) { ["hyrax/dashboard/profiles", "hyrax/users", "application"] }
  let(:view_paths) { ActionController::Base.view_paths }
  let(:lookup_context) { ActionView::LookupContext.new(view_paths, details, prefixes) }

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

