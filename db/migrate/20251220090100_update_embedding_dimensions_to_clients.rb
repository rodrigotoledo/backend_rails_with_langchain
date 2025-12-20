# frozen_string_literal: true

class UpdateEmbeddingDimensionsToClients < ActiveRecord::Migration[8.1]
  def up
    # Remove old embedding column
    remove_column :clients, :embedding if column_exists?(:clients, :embedding)

    # Add new embedding column with configurable dimensions
    # Default to 1536 for OpenAI text-embedding-3-small
    dimensions = ENV.fetch('AI_EMBEDDING_DIMENSIONS', 1536).to_i
    add_column :clients, :embedding, :vector, limit: dimensions

    # Add index for neighbor searches
    add_index :clients, :embedding, using: :hnsw, opclass: :vector_cosine_ops
  end

  def down
    remove_index :clients, :embedding if index_exists?(:clients, :embedding)
    remove_column :clients, :embedding
  end
end
