# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::Actors::JSONFieldsActor do
  let(:ability) { ::Ability.new(user) }
  let(:env) { env_class.new(work, ability, attributes) }
  let(:terminator) { Hyrax::Actors::Terminator.new }
  let(:user) { build(:user) }
  let(:work) { create(:generic_work) }
  let(:env_class) { Hyrax::Actors::Environment }
  let(:attributes) { {} }

  let(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
      middleware.use Hyrax::Actors::ModelActor
    end

    stack.build(terminator)
  end

  describe "#create" do
    before do
      allow(terminator).to receive(:create).with(env)
      middleware.create(env)
    end

    context "non-json fields" do
      let(:attributes) { { title: ["Moomin"] } }
      let(:transformed_attributes) { { "title" => ["Moomin"] } }

      it "passes non-json fields through" do
        expect(env.attributes[:title]).to eq(transformed_attributes["title"])
      end
    end

    context "with multiple valid json fields" do
      let(:attributes) do
        {
          creator: [
            { "creator_name_type" => "Personal", "creator_given_name" => "Liang", "creator_family_name" => "Gao" },
            { "creator_name_type" => "Personal", "creator_given_name" => "Lidai", "creator_family_name" => "Wang" }
          ],
          editor: [
            { "editor_name_type" => "Personal", "editor_given_name" => "Alexander A.", "editor_family_name" => "Oraevsky" },
            { "editor_name_type" => "Personal", "editor_given_name" => "Lihong V.", "editor_family_name" => "Wang" }
          ]
        }
      end

      let(:transformed_attributes) do
        { "creator" => ["[{\"creator_name_type\":\"Personal\",\"creator_given_name\":\"Liang\",\"creator_family_name\":\"Gao\"},{\"creator_name_type\":\"Personal\",\"creator_given_name\":\"Lidai\",\"creator_family_name\":\"Wang\"}]"], "editor" => ["[{\"editor_name_type\":\"Personal\",\"editor_given_name\":\"Alexander A.\",\"editor_family_name\":\"Oraevsky\"},{\"editor_name_type\":\"Personal\",\"editor_given_name\":\"Lihong V.\",\"editor_family_name\":\"Wang\"}]"], "contributor" => [], "funder" => [], "alternate_identifier" => [], "related_identifier" => [], "current_he_institution" => [] }
      end

      it "adds them all" do
        expect(env.attributes).to eq(transformed_attributes)
      end
    end

    context "with blank or empty attributes" do
      let(:attributes) do
        {
          creator: [
            {}
          ],
          editor: [
            { "editor_name_type" => "Personal", "editor_given_name" => "Alexander A.", "editor_family_name" => nil }
          ]
        }
      end

      let(:transformed_attributes) do
        { "editor" => ["[{\"editor_name_type\":\"Personal\",\"editor_given_name\":\"Alexander A.\",\"editor_family_name\":null}]"], "creator" => [], "contributor" => [], "funder" => [], "alternate_identifier" => [], "related_identifier" => [], "current_he_institution" => [] }
      end

      it "turns fields into null or adds empty arrays" do
        expect(env.attributes).to eq(transformed_attributes)
      end
    end

    context "with no name type" do
      let(:attributes) do
        {
          editor: [
            { "editor_name_type" => "", "editor_given_name" => "Lihong V.", "editor_family_name" => "Wang" }
          ]
        }
      end

      let(:transformed_attributes) do
        { "editor" => ["[{\"editor_name_type\":\"\",\"editor_given_name\":\"Lihong V.\",\"editor_family_name\":\"Wang\"}]"], "creator" => [], "contributor" => [], "funder" => [], "alternate_identifier" => [], "related_identifier" => [], "current_he_institution" => [] }
      end

      it "adds the attributes" do
        expect(env.attributes).to eq(transformed_attributes)
      end
    end

    context "with nested fields" do
      let(:attributes) do
        {
          creator: [
            { "creator_name_type" => "Personal", "creator_given_name" => "Liang", "creator_family_name" => "Gao" },
            { "creator_name_type" => "Personal", "creator_given_name" => "Lidai", "creator_family_name" => "Wang" },
            { "creator_name_type" => "Personal", "creator_given_name" => "Chiye", "creator_family_name" => "Li" },
            { "creator_name_type" => "Personal", "creator_given_name" => "Yan", "creator_family_name" => "Liu" },
            creator: [
              { "creator_name_type" => "Personal", "creator_given_name" => "Haixin", "creator_family_name" => "Ke" },
              { "creator_name_type" => "Personal", "creator_given_name" => "Chi", "creator_family_name" => "Zhang" },
              { "creator_name_type" => "Personal", "creator_given_name" => "Lihong V.", "creator_family_name" => "Wang" }
            ]
          ]
        }
      end

      let(:transformed_attributes) do
        { "creator" => ["[{\"creator_name_type\":\"Personal\",\"creator_given_name\":\"Liang\",\"creator_family_name\":\"Gao\"},{\"creator_name_type\":\"Personal\",\"creator_given_name\":\"Lidai\",\"creator_family_name\":\"Wang\"},{\"creator_name_type\":\"Personal\",\"creator_given_name\":\"Chiye\",\"creator_family_name\":\"Li\"},{\"creator_name_type\":\"Personal\",\"creator_given_name\":\"Yan\",\"creator_family_name\":\"Liu\"},{\"creator\":[{\"creator_name_type\":\"Personal\",\"creator_given_name\":\"Haixin\",\"creator_family_name\":\"Ke\"},{\"creator_name_type\":\"Personal\",\"creator_given_name\":\"Chi\",\"creator_family_name\":\"Zhang\"},{\"creator_name_type\":\"Personal\",\"creator_given_name\":\"Lihong V.\",\"creator_family_name\":\"Wang\"}]}]"], "contributor" => [], "funder" => [], "alternate_identifier" => [], "related_identifier" => [], "editor" => [], "current_he_institution" => [] }
      end

      it "recurses through them" do
        expect(env.attributes).to eq(transformed_attributes)
      end
    end
  end

  describe "#update" do
    let(:work) { create :generic_work, original_attributes }

    before do
      allow(terminator).to receive(:update).with(env)
      middleware.update(env)
    end

    context "non-json fields" do
      let(:original_attributes) { { title: ["Test Name"] } }
      let(:attributes) { { title: ["Moomin"] } }
      let(:transformed_attributes) { { "title" => ["Moomin"] } }

      it "passes non-json fields through" do
        expect(env.attributes[:title]).to eq(transformed_attributes["title"])
      end
    end

    context "with multiple json fields" do
      let(:original_attributes) do
        {
          creator: [
            [{
              creator_name_type: "Personal",
              creator_given_name: "Johnny",
              creator_family_name: "Testison"
            }].to_json
          ]
        }
      end

      let(:attributes) do
        {
          creator: [
            { "creator_name_type" => "Personal", "creator_given_name" => "Liang", "creator_family_name" => "Gao" },
            { "creator_name_type" => "Personal", "creator_given_name" => "Lidai", "creator_family_name" => "Wang" }
          ],
          editor: [
            { "editor_name_type" => "Personal", "editor_given_name" => "Alexander A.", "editor_family_name" => "Oraevsky" },
            { "editor_name_type" => "Personal", "editor_given_name" => "Lihong V.", "editor_family_name" => "Wang" }
          ]
        }
      end

      let(:transformed_attributes) do
        { "creator" => ["[{\"creator_name_type\":\"Personal\",\"creator_given_name\":\"Liang\",\"creator_family_name\":\"Gao\"},{\"creator_name_type\":\"Personal\",\"creator_given_name\":\"Lidai\",\"creator_family_name\":\"Wang\"}]"], "editor" => ["[{\"editor_name_type\":\"Personal\",\"editor_given_name\":\"Alexander A.\",\"editor_family_name\":\"Oraevsky\"},{\"editor_name_type\":\"Personal\",\"editor_given_name\":\"Lihong V.\",\"editor_family_name\":\"Wang\"}]"], "contributor" => [], "funder" => [], "alternate_identifier" => [], "related_identifier" => [], "current_he_institution" => [] }
      end

      it "adds them all" do
        expect(env.attributes).to eq(transformed_attributes)
      end
    end

    context "with blank or empty attributes" do
      let(:original_attributes) do
        {
          creator: [
            [{
              creator_name_type: "Personal",
              creator_given_name: "Johnny",
              creator_family_name: "Testison"
            }].to_json
          ],
          editor: [
            [{
              creator_name_type: "Personal",
              creator_given_name: "Johnny",
              creator_family_name: "Testison"
            }].to_json
          ]
        }
      end
      let(:attributes) do
        {
          creator: [
            {}
          ],
          editor: [
            { "editor_name_type" => "Personal", "editor_given_name" => "Alexander A.", "editor_family_name" => nil }
          ]
        }
      end

      let(:transformed_attributes) do
        { "editor" => ["[{\"editor_name_type\":\"Personal\",\"editor_given_name\":\"Alexander A.\",\"editor_family_name\":null}]"], "creator" => [], "contributor" => [], "funder" => [], "alternate_identifier" => [], "related_identifier" => [], "current_he_institution" => [] }
      end

      it "turns fields into null or adds empty arrays" do
        expect(env.attributes).to eq(transformed_attributes)
      end
    end

    context "with no name type" do
      let(:original_attributes) do
        {
          editor: [
            [{
              creator_name_type: "Personal",
              creator_given_name: "Johnny",
              creator_family_name: "Testison"
            }].to_json
          ]
        }
      end
      let(:attributes) do
        {
          editor: [
            { "editor_name_type" => "", "editor_given_name" => "Lihong V.", "editor_family_name" => "Wang" }
          ]
        }
      end

      let(:transformed_attributes) do
        { "editor" => ["[{\"editor_name_type\":\"\",\"editor_given_name\":\"Lihong V.\",\"editor_family_name\":\"Wang\"}]"], "creator" => [], "contributor" => [], "funder" => [], "alternate_identifier" => [], "related_identifier" => [], "current_he_institution" => [] }
      end

      it "adds the attributes" do
        expect(env.attributes).to eq(transformed_attributes)
      end
    end

    context "with nested fields" do
      let(:original_attributes) do
        {
          creator: [
            [{
              creator_name_type: "Personal",
              creator_given_name: "Johnny",
              creator_family_name: "Testison"
            }].to_json
          ]
        }
      end
      let(:attributes) do
        {
          creator: [
            { "creator_name_type" => "Personal", "creator_given_name" => "Liang", "creator_family_name" => "Gao" },
            { "creator_name_type" => "Personal", "creator_given_name" => "Lidai", "creator_family_name" => "Wang" },
            { "creator_name_type" => "Personal", "creator_given_name" => "Chiye", "creator_family_name" => "Li" },
            { "creator_name_type" => "Personal", "creator_given_name" => "Yan", "creator_family_name" => "Liu" },
            creator: [
              { "creator_name_type" => "Personal", "creator_given_name" => "Haixin", "creator_family_name" => "Ke" },
              { "creator_name_type" => "Personal", "creator_given_name" => "Chi", "creator_family_name" => "Zhang" },
              { "creator_name_type" => "Personal", "creator_given_name" => "Lihong V.", "creator_family_name" => "Wang" }
            ]
          ]
        }
      end

      let(:transformed_attributes) do
        { "creator" => ["[{\"creator_name_type\":\"Personal\",\"creator_given_name\":\"Liang\",\"creator_family_name\":\"Gao\"},{\"creator_name_type\":\"Personal\",\"creator_given_name\":\"Lidai\",\"creator_family_name\":\"Wang\"},{\"creator_name_type\":\"Personal\",\"creator_given_name\":\"Chiye\",\"creator_family_name\":\"Li\"},{\"creator_name_type\":\"Personal\",\"creator_given_name\":\"Yan\",\"creator_family_name\":\"Liu\"},{\"creator\":[{\"creator_name_type\":\"Personal\",\"creator_given_name\":\"Haixin\",\"creator_family_name\":\"Ke\"},{\"creator_name_type\":\"Personal\",\"creator_given_name\":\"Chi\",\"creator_family_name\":\"Zhang\"},{\"creator_name_type\":\"Personal\",\"creator_given_name\":\"Lihong V.\",\"creator_family_name\":\"Wang\"}]}]"], "contributor" => [], "funder" => [], "alternate_identifier" => [], "related_identifier" => [], "editor" => [], "current_he_institution" => [] }
      end

      it "recurses through them" do
        expect(env.attributes).to eq(transformed_attributes)
      end
    end
  end
end
