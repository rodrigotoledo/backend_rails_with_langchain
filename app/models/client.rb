# frozen_string_literal: true

class Client < ApplicationRecord
  has_many :addresses, dependent: :destroy
  has_many :uploads, dependent: :destroy
  accepts_nested_attributes_for :addresses, allow_destroy: true

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :cpf, presence: true, length: { is: 11 }, numericality: { only_integer: true }
  validates :birth_date, presence: true

  def full_name
    "#{name} #{nickname}".strip
  end
end
