# frozen_string_literal: true

module HykuAddons
  class CreatorPresenter
    def display_creator(creators)
      @value_array = []
      parsed_json = JSON.parse(creators.first)
      parsed_json.each do |creator|
        if creator["creator_name_type"] == "Personal"
          creator_personal_array(creator)
        else
          creator_org_array(creator)
        end
      end
      @value_array
    end

    def creator_personal_array(creator)
      array = []
      array << creator["creator_family_name"]
      array << creator["creator_given_name"]
      @value_array << array.join(",")
    end

    def creator_org_array(creator)
      @value_array << creator["creator_organization_name"]
    end
  end
end
