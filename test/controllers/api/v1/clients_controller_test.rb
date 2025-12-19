# frozen_string_literal: true

require "test_helper"

class Api::V1::ClientsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_v1_clients_url
    assert_response :success
  end

  test "should create client" do
    assert_difference("Client.count") do
      post api_v1_clients_url, params: {
        name: "Jane Doe",
        email: "jane@example.com",
        documents: { cpf: "98765432100", birth_date: "1995-05-05" },
        addresses: [
          {
            address_type: "Pessoal",
            street: "Rua B",
            number: "456",
            neighborhood: "Centro",
            city: "Rio",
            state: "RJ",
            zip_code: "20000-000"
          }
        ]
      }, as: :json
    end
    assert_response :created
  end
end
