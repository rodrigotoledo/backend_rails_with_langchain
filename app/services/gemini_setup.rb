# frozen_string_literal: true

# app/services/gemini_setup.rb
require "gemini-ai"

class GeminiSetup
  def self.create_store(display_name: "ClientsStore")
    client = Gemini::Client.new(
      credentials: { api_key: ENV["GEMINI_API_KEY"] }  # ou Vertex AI config
    )

    # Cria o File Search Store via REST (gem não tem método direto, então usa request raw)
    response = client.request(
      :post,
      "/v1beta/fileSearchStores",
      body: { config: { display_name: display_name } }.to_json,
      headers: { "Content-Type" => "application/json" }
    )

    JSON.parse(response.body)["name"]  # ex: "projects/SEU_PROJ/locations/us/fileSearchStores/clientes-store-abc"
  end
end
