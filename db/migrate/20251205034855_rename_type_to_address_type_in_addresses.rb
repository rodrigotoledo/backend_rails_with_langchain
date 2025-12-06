# frozen_string_literal: true

class RenameTypeToAddressTypeInAddresses < ActiveRecord::Migration[8.1]
  def change
    rename_column :addresses, :type, :address_type
  end
end
