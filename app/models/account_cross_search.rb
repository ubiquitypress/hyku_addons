# frozen_string_literal: true

# adds many to many shared search
class AccountCrossSearch < ApplicationRecord
  belongs_to :search_account, class_name: "Account"
  belongs_to :full_account, class_name: "Account"

  accepts_nested_attributes_for :search_account
  accepts_nested_attributes_for :full_account
end
