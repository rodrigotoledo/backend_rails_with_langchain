# frozen_string_literal: true

# app/services/client_embedding_service.rb
# Service to generate and store embeddings for clients and their addresses
class ClientEmbeddingService
  def initialize
    @ai_service = AiEmbeddingService.new
  end

  # Sync all clients with embeddings
  def sync_all!
    Rails.logger.info "Starting embedding sync for all clients..."

    Client.includes(:addresses).find_each(batch_size: 50) do |client|
      sync_client(client)
      sleep 0.1 # Avoid rate limiting
    end

    Rails.logger.info "Embedding sync completed!"
  end

  # Sync a single client and its addresses
  # @param client [Client] The client to sync
  def sync_client(client)
    # Generate embedding for client
    client_text = build_client_text(client)
    client_embedding = @ai_service.embed(client_text)

    client.update!(embedding: client_embedding)
    Rails.logger.info "Synced client #{client.id}: #{client.name}"

    # Generate embeddings for each address
    client.addresses.each do |address|
      sync_address(address)
    end
  rescue => e
    Rails.logger.error "Failed to sync client #{client.id}: #{e.message}"
    raise
  end

  # Sync a single address
  # @param address [Address] The address to sync
  def sync_address(address)
    address_text = build_address_text(address)
    address_embedding = @ai_service.embed(address_text)

    address.update!(embedding: address_embedding)
    Rails.logger.info "Synced address #{address.id} for client #{address.client_id}"
  rescue => e
    Rails.logger.error "Failed to sync address #{address.id}: #{e.message}"
    raise
  end

  # Search for similar clients using vector similarity
  # @param query [String] The search query
  # @param limit [Integer] Number of results to return
  # @return [ActiveRecord::Relation] Similar clients
  def search_clients(query, limit: 5)
    query_embedding = @ai_service.embed(query)

    Client.nearest_neighbors(
      :embedding,
      query_embedding,
      distance: "cosine"
    ).limit(limit)
  end

  # Search for similar addresses using vector similarity
  # @param query [String] The search query
  # @param limit [Integer] Number of results to return
  # @return [ActiveRecord::Relation] Similar addresses
  def search_addresses(query, limit: 5)
    query_embedding = @ai_service.embed(query)

    Address.nearest_neighbors(
      :embedding,
      query_embedding,
      distance: "cosine"
    ).limit(limit)
  end

  private

  def build_client_text(client)
    <<~TEXT
      Cliente: #{client.name}
      Apelido: #{client.nickname}
      Email: #{client.email}
      CPF: #{client.cpf}
      RG: #{client.rg}
      Telefone: #{client.phone}
      Data de Nascimento: #{client.birth_date&.strftime('%d/%m/%Y')}

      Endereços:
      #{client.addresses.map { |a| build_address_text(a) }.join("\n\n")}
    TEXT
  end

  def build_address_text(address)
    <<~TEXT
      Tipo: #{address.address_type}
      Endereço: #{address.street}, #{address.number}
      Complemento: #{address.complement}
      Bairro: #{address.neighborhood}
      Cidade: #{address.city}
      Estado: #{address.state}
      CEP: #{address.zip_code}
    TEXT
  end
end
