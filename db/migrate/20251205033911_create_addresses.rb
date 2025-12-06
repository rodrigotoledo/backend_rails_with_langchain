# frozen_string_literal: true

class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.references :client, null: false, foreign_key: true
      t.string :address_type
      t.string :street
      t.string :number
      t.string :complement
      t.string :neighborhood
      t.string :city
      t.string :state
      t.string :zip_code

      t.timestamps
    end
  end
end
