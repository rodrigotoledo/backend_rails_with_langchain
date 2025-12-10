# frozen_string_literal: true

class Address < ApplicationRecord
  vectorsearch

  after_save :upsert_to_vectorsearch

  belongs_to :client

  validates :street, :number, :neighborhood, :city, :state, :zip_code, presence: true
  validates :address_type, inclusion: { in: %w[Pessoal Comercial] }

  def full_address
    [ street, number, complement, neighborhood, city, state, zip_code ].compact.join(", ")
  end
end
