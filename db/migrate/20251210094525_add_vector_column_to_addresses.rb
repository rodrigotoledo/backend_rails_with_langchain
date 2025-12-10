# frozen_string_literal: true

class AddVectorColumnToAddresses < ActiveRecord::Migration[8.1]
  def change
    add_column :addresses, :embedding, :vector,
      limit: LangchainrbRails
        .config
        .vectorsearch
        .llm
        .default_dimensions
  end
end
