# frozen_string_literal: true

class CreateUploads < ActiveRecord::Migration[8.1]
  def change
    create_table :uploads do |t|
      t.references :client, null: false, foreign_key: true
      t.string :context
      t.jsonb :processors, default: [ 'DocumentProcessor' ]

      t.timestamps
    end
  end
end
