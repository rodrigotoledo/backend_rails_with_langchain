# frozen_string_literal: true

class Address < ApplicationRecord
  belongs_to :client

  validates :street, :number, :neighborhood, :city, :state, :zip_code, presence: true
  validates :address_type, inclusion: { in: %w[Pessoal Comercial] }
end
