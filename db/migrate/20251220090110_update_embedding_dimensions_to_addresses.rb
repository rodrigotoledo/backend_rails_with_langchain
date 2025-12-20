# frozen_string_literal: true

class UpdateEmbeddingDimensionsToAddresses < ActiveRecord::Migration[8.1]
  def up
    # Remove old embedding column
    remove_column :addresses, :embedding if column_exists?(:addresses, :embedding)

    # Add new embedding column with configurable dimensions
    # Default to 1536 for OpenAI text-embedding-3-small
    dimensions = ENV.fetch('AI_EMBEDDING_DIMENSIONS', 1536).to_i
    add_column :addresses, :embedding, :vector, limit: dimensions

    # Add index for neighbor searches
    add_index :addresses, :embedding, using: :hnsw, opclass: :vector_cosine_ops
  end

  def down
    remove_index :addresses, :embedding if index_exists?(:addresses, :embedding)
    remove_column :addresses, :embedding
  end
end
