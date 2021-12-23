# frozen_string_literal: true
# Some of these fields we don't currently have a way to set, I will leave it up to
# Elisa or Tom if they want to allow users to set any of these fields for the Frontend Profile
json.id user.id
json.email user.email
json.display_name user.display_name
json.biography user.biography
json.facebook_handle user.facebook_handle
json.twitter_handle user.twitter_handle
json.googleplus_handle user.googleplus_handle
json.linkedin_handle user.linkedin_handle
json.orcid user.orcid
json.address user.address
json.department user.department
json.title user.title
json.office user.office
json.chat_id user.chat_id
json.title user.title
json.office user.office
json.website user.website
json.affiliation user.affiliation
json.telephone user.telephone
json.avatar_file_name user.avatar_file_name
json.avatar_content_type user.avatar_content_type
json.avatar_file_size user.avatar_file_size
json.avatar_updated_at user.avatar_updated_at

json.works do
  json.partial! 'hyku/api/v1/work/work', collection: @user_works, as: :work, collection_docs: @collection_docs
end
