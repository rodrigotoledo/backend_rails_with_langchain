# frozen_string_literal: true

# app/services/gemini_clients_sync_service.rb
require "gemini-ai"
class GeminiClientsSyncService
  STORE_DISPLAY_NAME = "ClientesRAG".freeze

  def initialize
    @api_key     = ENV.fetch("GEMINI_API_KEY")
    @client      = Gemini.new(
      credentials: { service: "generative-language-api", api_key: @api_key },
      options: { model: "gemini-2.0-flash", server_sent_events: true }
    )
    @store_name  = ensure_store_exists
  end

  # Chame assim:
  # GeminiClientsSyncService.new.sync_all!
  # ou
  # GeminiClientsSyncService.new.sync_client(123)
  def sync_all!
    Rails.logger.info "Iniciando sync de todos os clientes para Gemini File Search..."

    Client.includes(:addresses).find_each(batch_size: 50) do |client|
      sync_client(client)
      sleep 0.3 # evita rate limit (pode tirar se tiver muitos)
    end

    Rails.logger.info "Sync concluído! Store: #{@store_name}"
  end

  def sync_client(client)
    md_content = build_markdown(client)
    temp_file  = Tempfile.new([ "client_#{client.id}", ".md" ], binmode: true)
    temp_file.write(md_content)
    temp_file.rewind

    upload_to_gemini(temp_file.path, client.id)

    temp_file.close
    temp_file.unlink
  rescue => e
    Rails.logger.error "Falha ao sincronizar cliente #{client.id}: #{e.message}"
  end

  def build_markdown(client)
    <<~MD
      # Cliente #{client.id} — #{client.name}

      **clientId**: #{client.id}
      **name**: #{client.name}
      **nickname**: #{client.nickname.presence || "Não informado"}
      **email**: #{client.email}
      **cpf**: #{client.cpf.presence || "Não informado"}
      **rg**: #{client.rg.presence || "Não informado"}
      **phone**: #{client.phone.presence || "Não informado"}
      **birthDate**: #{client.birth_date&.strftime("%d/%m/%Y") || "Não informado"}

      ## Endereços

      #{client.addresses.map.with_index(1) { |a, i| address_section(a, i) }.join("\n\n") || "Nenhum endereço cadastrado"}

      ---
    MD
  end

  def address_section(address, index)
    <<~ADDR
      ### Endereço #{index} — #{address.address_type || "Principal"}

      **addressId**: #{address.id}
      **addressType**: #{address.address_type.presence || "Não informado"}
      **street**: #{address.street}
      **number**: #{address.number}
      **complement**: #{address.complement.presence || "Sem complemento"}
      **neighborhood**: #{address.neighborhood}
      **city**: #{address.city}
      **state**: #{address.state}
      **zipCode**: #{format_zip(address.zip_code)}
      **fullAddress**: #{full_address_line(address)}
    ADDR
  end

  def full_address_line(address)
    [
      address.street,
      address.number,
      address.complement,
      address.neighborhood,
      address.city,
      address.state,
      address.zip_code
    ].compact.reject(&:empty?).join(", ")
  end

  def format_zip(zip)
    return "Não informado" if zip.blank?
    zip.gsub(/^(\d{5})(\d{3})$/, '\\1-\\2')
  end

  def ensure_store_exists
    conn = Faraday.new(url: "https://generativelanguage.googleapis.com")

    # 1. Listar stores existentes
    response = conn.get("/v1beta/fileSearchStores") do |req|
      req.params["key"] = @api_key
    end

    if response.status == 200
      stores = JSON.parse(response.body).dig("fileSearchStores") || []
      existing = stores.find { |s| s["displayName"] == STORE_DISPLAY_NAME }
      return existing["name"] if existing
    else
      Rails.logger.warn "Não foi possível listar stores: #{response.status} #{response.body}"
    end

    # 2. Criar nova store com o payload DIRETO (sem wrapper!)
    create_resp = conn.post("/v1beta/fileSearchStores") do |req|
      req.params["key"] = @api_key
      req.headers["Content-Type"] = "application/json"
      req.body = { displayName: STORE_DISPLAY_NAME }.to_json  # ← AQUI: direto no root
    end

    if create_resp.status == 200
      store_name = JSON.parse(create_resp.body)["name"]
      Rails.logger.info "File Search Store criada com sucesso: #{store_name}"
      store_name
    else
      error_body = begin
                    JSON.parse(create_resp.body)["error"]["message"]
                  rescue
                    create_resp.body
                  end
      raise "Falha ao criar File Search Store (#{create_resp.status}): #{error_body}"
    end
  end

  def upload_to_gemini(file_path, client_id)
    boundary = "==============#{SecureRandom.hex}"

    file_content = File.read(file_path)

    config_json = {
      config: {
        displayName: "Cliente #{client_id} — #{Time.current.strftime('%Y-%m-%d %H:%M')}",
        metadata: {
          clientId: client_id.to_s,
          syncedAt: Time.current.iso8601
        }
      }
    }.to_json

    body = []
    body << "--#{boundary}"
    body << "Content-Type: text/markdown"
    body << ""
    body << file_content
    body << "--#{boundary}"
    body << "Content-Type: application/json; charset=UTF-8"
    body << ""
    body << config_json
    body << "--#{boundary}--"
    body << ""

    conn = Faraday.new(url: "https://generativelanguage.googleapis.com") do |f|
      f.request :url_encoded
      f.adapter Faraday.default_adapter
    end

    resp = conn.post("/v1beta/#{@store_name}:uploadToFileSearchStore") do |req|
      req.params["key"] = @api_key
      req.headers["Content-Type"] = "multipart/related; boundary=#{boundary}"
      req.body = body.join("\r\n")
    end

    JSON.parse(resp.body)
  end


  def self.list_gemini_clients
  # Garante que a store existe (usa o método privado se precisar)
  service = GeminiClientsSyncService.new
  store_name = service.send(:ensure_store_exists)  # Chama privado pra criar/pegar

  puts "Store encontrada/fixada: #{store_name}"

  # Query pro Gemini com tool MÍNIMO (só file_search_store_names)
  conn = Faraday.new(url: "https://generativelanguage.googleapis.com")

  resposta = conn.post("/v1beta/models/gemini-2.0-flash-exp:generateContent?key=#{ENV['GEMINI_API_KEY']}") do |req|
    req.headers["Content-Type"] = "application/json"
    req.body = {
      contents: [
        {
          role: "user",
          parts: [ { text: "Liste em tabela markdown todos os clientes que você tem acesso agora. Inclua apenas: ID, nome completo e apelido. Se não tiver nenhum, diga exatamente: 'Nenhum cliente encontrado'." } ]
        }
      ],
      tools: [
        {
          file_search: {  # ← Tool correto e simples
            file_search_store_names: [ store_name ]  # ← Único campo obrigatório (array de stores)
            # Sem retrieval_mode, metadata_filter ou configs — isso causava os erros!
          }
        }
      ]
    }.to_json
  end

  if resposta.status == 200
    resultado = JSON.parse(resposta.body)
    texto = resultado.dig("candidates", 0, "content", "parts", 0, "text") || "Sem texto"

    # Checa se usou retrieval (pra confirmar que pegou da store)
    retrieval = resultado.dig("candidates", 0, "content", "parts", 0, "retrieval")
    if retrieval && retrieval["retrievalToolMetadata"]
      attributions = retrieval["retrievalToolMetadata"]["groundingAttributions"] || []
      puts "📄 Recuperou de: #{attributions.map { |a| a["title"] || a["uri"] }.join(', ')}"
    end

    puts "\nCLIENTES INDEXADOS NO GEMINI (#{store_name.split('/').last}):"
    puts "="*60
    puts texto.strip
    puts "="*60
  else
    puts "Erro na chamada: #{resposta.status}"
    puts resposta.body
  end
end
end
