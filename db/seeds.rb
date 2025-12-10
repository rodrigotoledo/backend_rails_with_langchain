# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'faker'

# Seed clients with random addresses
10.times do
  name = Faker::Name.name
  nickname = Faker::Name.first_name
  email = Faker::Internet.email
  phone = Faker::PhoneNumber.phone_number
  cpf = Faker::Number.number(digits: 11).to_s
  rg = Faker::Number.number(digits: 9).to_s
  birth_date = Faker::Date.birthday(min_age: 18, max_age: 65)

  num_addresses = rand(1..5)
  addresses_attributes = num_addresses.times.map do
    {
      address_type: [ "Pessoal", "Comercial" ].sample,
      street: Faker::Address.street_name,
      number: Faker::Address.building_number,
      complement: [ nil, Faker::Address.secondary_address ].sample,
      neighborhood: Faker::Address.community,
      city: Faker::Address.city,
      state: Faker::Address.state_abbr,
      zip_code: Faker::Address.zip_code
    }
  end

  Client.find_or_create_by!(email: email) do |client|
    client.name = name
    client.nickname = nickname
    client.phone = phone
    client.cpf = cpf
    client.rg = rg
    client.birth_date = birth_date
    client.addresses_attributes = addresses_attributes
  end
end


Client.find_or_create_by!(email: "john@example.com", name: "John Doe Toledo") do |client|
  client.nickname = "Johnny"
  client.phone = "555-1234",
  client.cpf = "00958373965"
  client.rg = "MG1234567"
  client.birth_date = Date.new(1990, 1, 1)
  client.addresses_attributes = [
    {
      address_type: "Pessoal",
      street: "Main St",
      number: "100",
      complement: "Apt 1",
      neighborhood: "Downtown",
      city: "Metropolis",
      state: "NY",
      zip_code: "12345"
    }
  ]
end


Client.find_or_create_by!(email: Faker::Internet.email, name: "#{Faker::Name.name_with_middle} John") do |client|
  client.nickname = "Johnny"
  client.phone = "555-1234",
  client.cpf = "00958373965"
  client.rg = "MG1234567"
  client.birth_date = Date.new(1990, 1, 1)
  client.addresses_attributes = [
    {
      address_type: "Pessoal",
      street: "Main St",
      number: "100",
      complement: "Apt 1",
      neighborhood: "Downtown",
      city: "Metropolis",
      state: "NY",
      zip_code: "12345"
    }
  ]
end
