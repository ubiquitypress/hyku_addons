# frozen_string_literal: true
class AddDataCiteEndpointToAccount < ActiveRecord::Migration[5.2]
  def change
    add_reference :accounts, :datacite_endpoint, index: true unless column_exists?(:accounts, :datacite_endpoint_id)
  end
end
