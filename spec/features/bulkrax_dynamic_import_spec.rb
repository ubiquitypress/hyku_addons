# frozen_string_literal: true

require "rails_helper"
require "yaml"
require "csv"

RSpec.describe "Bulkrax import", clean: true, slow: true do
  let(:model_name)  { "UbiquityTemplateWork" }
  let(:number_of_records) { 2 }

  let(:user) { create(:user, email: "test@example.com") }
  let!(:depositor) { build_stubbed(:user, email: "batchuser@example.com") }
  let(:temp_file_path) { "spec/fixtures/csv/dynamic_data.csv" }

  let(:importer) do
    create(:bulkrax_importer_csv,
           user: user,
           field_mapping: Bulkrax.field_mappings["HykuAddons::CsvParser"],
           parser_klass: "HykuAddons::CsvParser",
           parser_fields: { "import_file_path" => temp_file_path },
           limit: 0)
  end

  after do
    File.delete(temp_file_path) if File.exist?(temp_file_path)
  end

  before do
    # Make sure default admin set exists
    AdminSet.find_or_create_default_admin_set_id
    stub_request(:get, Addressable::Template.new("#{Hyrax::Hirmeos::MetricsTracker.translation_base_url}/translate?uri=urn:uuid:{id}")).to_return(status: 200)
    allow(Hyrax::Hirmeos::HirmeosFileUpdaterJob).to receive(:perform_later)
    create_csv
  end

  describe "import works" do
    before do
      perform_enqueued_jobs(only: Bulkrax::ImporterJob) do
        importer.import_collections
      end
    end

    it "imports works" do
      expect do
        perform_enqueued_jobs(only: Bulkrax::ImporterJob) do
          importer.import_works
        end
      end.to change { model_name.constantize.count }.by(number_of_records)

      aggregate_failures "testing response" do
        CSV.read(temp_file_path, headers: true).each do |row|

          work = model_name.constantize.where(source_identifier: row["source_identifier"]).first
          counter = row["source_identifier"].split("-").last.to_i
          
          schema_data.keys.each do |attribute|
            if work.respond_to?(attribute) && !untested_attributes.include?(attribute)
              puts "#{attribute}: #{work.send(attribute)}"
              if schema_data[attribute]["subfields"].present?
                schema_data[attribute]["subfields"].keys.each do |sub_field|
                  if !untested_attributes.include?(sub_field)
                    expect(eval(work.send(attribute).first).first[sub_field.to_sym]).to eq(attribute_data(sub_field, counter))
                  end
                end
              else
                if schema_data[attribute]["multiple"]
                  expect(work.send(attribute)).to eq([attribute_data(attribute, counter)])
                else
                  expect(work.send(attribute)).to eq(attribute_data(attribute, counter))
                end
              end
            end
          end
        end
      end
    end
  end

  private

    def untested_attributes
      %w(resource_type language rights_statement relation_type subject display_creator_profile)
    end

    def attributes
      data = schema_data.dup
      data.delete_if { |k, v| v.key?("subfields") || untested_attributes.include?(k)  }
      data.merge!(subfields)
    end

    def header_names
      data = schema_data.dup
      data.delete_if { |k, v| v.key?("subfields") || untested_attributes.include?(k) }
      data.merge!(subfields.transform_keys { |k| k + "_1" })
    end

    def required_header_names 
      header_names.select { |_k, v| v["form"]["required"] }.keys
    end

    def optional_header_names
      header_names.reject { |_k, v| v["form"]["required"] }.keys
    end
    
    def required_attributes 
      attributes.select { |k, v| v["form"]["required"] } 
    end

    def optional_attributes
      attributes.reject { |_k, v| v["form"]["required"] } 
    end

    def headers
      # TODO: get value for resource type
      %w[id source_identifier model depositor] + required_header_names + optional_header_names
    end

    def schema_data
      YAML.load_file("/home/app/config/metadata/ubiquity_template_work.yaml")["attributes"]
    end

    def subfields
      schema_data.map { |_k, v| v["subfields"] if v.key?("subfields") }
                 .compact
                 .reduce({}, :merge)
    end

    # TODO: Use factories to set default values

    def create_csv
      File.delete(temp_file_path) if File.exist?(temp_file_path)
      file = File.new(temp_file_path, "wb")

      csv = CSV.open(file, "wb", headers: headers, write_headers: true) do |row|
        number_of_records.times.each do |i|
          row << ["id-#{i}", "source-#{i}", model_name, depositor.email] + field_data(i)
        end
      end

      file.close
    end

   

    def field_data(i)
      required_attributes.collect { |attribute| attribute_data(attribute.first, i) } +
      optional_attributes.collect { |attribute| attribute_data(attribute.first, i) }
    end

    def attribute_data(name, i)
      return unless name.is_a? String

      case name
      when "creator_name_type_1"
        "Personal"
      else
        "#{name}-#{i}"
      end
    end
end
