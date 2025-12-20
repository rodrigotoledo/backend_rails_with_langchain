# frozen_string_literal: true

class Client < ApplicationRecord
  # Neighbor gem for vector similarity search
  has_neighbors :embedding, dimensions: -> { ENV.fetch("AI_EMBEDDING_DIMENSIONS", 1536).to_i }

  # Associations
  has_many :addresses, dependent: :destroy
  has_many :uploads, dependent: :destroy
  accepts_nested_attributes_for :addresses, allow_destroy: true

  has_many :client_personal_vectors, dependent: :destroy
  has_many :client_contact_vectors,  dependent: :destroy
  has_many :client_address_vectors, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :cpf, presence: true, length: { is: 11 }, numericality: { only_integer: true }
  validates :birth_date, presence: true

  # Callbacks
  after_save :sync_embedding, if: :should_sync_embedding?

  def full_name
    "#{name} #{nickname}".strip
  end

  # Search similar clients by text query
  # @param query [String] The search query
  # @param limit [Integer] Number of results
  # @return [ActiveRecord::Relation]
  def self.search_by_similarity(query, limit: 5)
    ClientEmbeddingService.new.search_clients(query, limit: limit)
  end

  private

  def should_sync_embedding?
    relevant_changes? && ENV["AI_PROVIDER"].present?
  end

  def relevant_changes?
    saved_change_to_name? ||
    saved_change_to_email? ||
    saved_change_to_cpf? ||
    saved_change_to_phone?
  end

  def sync_embedding
    ClientEmbeddingService.new.sync_client(self)
  rescue => e
    Rails.logger.error "Failed to sync embedding for client #{id}: #{e.message}"
  end
end
