# frozen_string_literal: true

class Address < ApplicationRecord
  # Neighbor gem for vector similarity search
  has_neighbors :embedding, dimensions: -> { ENV.fetch("AI_EMBEDDING_DIMENSIONS", 1536).to_i }

  # Associations
  belongs_to :client

  # Validations
  validates :street, :number, :neighborhood, :city, :state, :zip_code, presence: true
  validates :address_type, inclusion: { in: %w[Pessoal Comercial] }

  # Callbacks
  after_save :sync_embedding, if: :should_sync_embedding?

  def full_address
    [ street, number, complement, neighborhood, city, state, zip_code ].compact.join(", ")
  end

  # Search similar addresses by text query
  # @param query [String] The search query
  # @param limit [Integer] Number of results
  # @return [ActiveRecord::Relation]
  def self.search_by_similarity(query, limit: 5)
    ClientEmbeddingService.new.search_addresses(query, limit: limit)
  end

  private

  def should_sync_embedding?
    persisted? && ENV["AI_PROVIDER"].present?
  end

  def sync_embedding
    ClientEmbeddingService.new.sync_address(self)
  rescue => e
    Rails.logger.error "Failed to sync embedding for address #{id}: #{e.message}"
  end
end
