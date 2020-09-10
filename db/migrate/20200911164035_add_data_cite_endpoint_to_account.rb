# frozen_string_literal: true
class AddDataCiteEndpointToAccount < ActiveRecord::Migration[5.2]
  def change
    add_reference :accounts, :datacite_endpoint, index: true
  end
end
