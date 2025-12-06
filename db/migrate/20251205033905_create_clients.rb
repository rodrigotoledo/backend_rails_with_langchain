# frozen_string_literal: true

class CreateClients < ActiveRecord::Migration[8.1]
  def change
    create_table :clients do |t|
      t.string :name
      t.string :nickname
      t.string :email
      t.string :phone
      t.string :cpf
      t.string :rg
      t.date :birth_date

      t.timestamps
    end
    add_index :clients, :email, unique: true
  end
end
