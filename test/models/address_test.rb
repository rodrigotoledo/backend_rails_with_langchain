require "test_helper"

class AddressTest < ActiveSupport::TestCase
  test "should be valid" do
    client = Client.create!(
      name: "John Doe",
      email: "john@example.com",
      cpf: "12345678901",
      birth_date: Date.new(1990, 1, 1)
    )
    address = Address.new(
      client: client,
      address_type: "Pessoal",
      street: "Rua A",
      number: "123",
      neighborhood: "Centro",
      city: "São Paulo",
      state: "SP",
      zip_code: "01234-567"
    )
    assert address.valid?
  end

  test "full_address" do
    client = Client.create!(
      name: "John Doe",
      email: "john@example.com",
      cpf: "12345678901",
      birth_date: Date.new(1990, 1, 1)
    )
    address = Address.create!(
      client: client,
      address_type: "Pessoal",
      street: "Rua A",
      number: "123",
      complement: "Apto 1",
      neighborhood: "Centro",
      city: "São Paulo",
      state: "SP",
      zip_code: "01234-567"
    )
    assert_equal "Rua A, 123, Apto 1, Centro, São Paulo, SP, 01234-567", address.full_address
  end
end
