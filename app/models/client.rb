# frozen_string_literal: true

class Client < ApplicationRecord
  # vectorsearch

  # after_save :upsert_to_vectorsearch
  after_save :sync_to_gemini, if: :relevant_change?

  has_many :addresses, dependent: :destroy
  has_many :uploads, dependent: :destroy
  accepts_nested_attributes_for :addresses, allow_destroy: true

  has_many :client_personal_vectors, dependent: :destroy
  has_many :client_contact_vectors,  dependent: :destroy
  has_many :client_address_vectors, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :cpf, presence: true, length: { is: 11 }, numericality: { only_integer: true }
  validates :birth_date, presence: true

  def full_name
    "#{name} #{nickname}".strip
  end

  # def as_vector
  #   { name: full_name, email: email }.to_json(except: :embedding)
  # end
  #
  private
  def relevant_change?
    saved_change_to_name? || saved_change_to_email? || addresses.any?(&:saved_changes?)
  end

  def sync_to_gemini
    GeminiClientsSyncService.new.sync_client(self)
  end
end
