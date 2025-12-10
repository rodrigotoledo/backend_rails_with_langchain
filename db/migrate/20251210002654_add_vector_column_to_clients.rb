# frozen_string_literal: true

class AddVectorColumnToClients < ActiveRecord::Migration[8.1]
  def change
    add_column :clients, :embedding, :vector,
      limit: LangchainrbRails
        .config
        .vectorsearch
        .llm
        .default_dimensions
  end
end
