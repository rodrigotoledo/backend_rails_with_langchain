# frozen_string_literal: true

require "test_helper"

class ClientTest < ActiveSupport::TestCase
  test "should be valid" do
    client = Client.new(
      name: "John Doe",
      email: "john@example.com",
      cpf: "12345678901",
      birth_date: Date.new(1990, 1, 1)
    )
    assert client.valid?
  end
end
