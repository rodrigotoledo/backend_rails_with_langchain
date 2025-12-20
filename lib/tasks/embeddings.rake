# frozen_string_literal: true

# lib/tasks/embeddings.rake
namespace :embeddings do
  desc "Sync all clients and addresses embeddings"
  task sync_all: :environment do
    puts "Starting embedding sync..."
    puts "Provider: #{ENV['AI_PROVIDER']}"
    puts "Model: #{ENV.fetch('AI_EMBEDDING_MODEL', 'default')}"
    puts "Dimensions: #{ENV.fetch('AI_EMBEDDING_DIMENSIONS', 1536)}"
    puts ""

    service = ClientEmbeddingService.new
    service.sync_all!

    puts ""
    puts "✅ Sync completed!"
  end

  desc "Sync a single client by ID"
  task :sync_client, [ :client_id ] => :environment do |_t, args|
    client_id = args[:client_id]

    unless client_id
      puts "❌ Error: Please provide a client ID"
      puts "Usage: rails embeddings:sync_client[123]"
      exit 1
    end

    client = Client.find(client_id)
    service = ClientEmbeddingService.new
    service.sync_client(client)

    puts "✅ Client #{client.name} synced successfully!"
  rescue ActiveRecord::RecordNotFound
    puts "❌ Error: Client with ID #{client_id} not found"
    exit 1
  end

  desc "Test embedding search"
  task :search, [ :query ] => :environment do |_t, args|
    query = args[:query]

    unless query
      puts "❌ Error: Please provide a search query"
      puts "Usage: rails embeddings:search['João Silva']"
      exit 1
    end

    puts "Searching for: #{query}"
    puts "Provider: #{ENV['AI_PROVIDER']}"
    puts ""

    service = ClientEmbeddingService.new

    puts "=== Clients ==="
    clients = service.search_clients(query, limit: 5)
    clients.each_with_index do |client, i|
      puts "#{i + 1}. #{client.name} (#{client.email})"
    end

    puts ""
    puts "=== Addresses ==="
    addresses = service.search_addresses(query, limit: 5)
    addresses.each_with_index do |address, i|
      puts "#{i + 1}. #{address.full_address} (Client: #{address.client.name})"
    end
  end

  desc "Show embedding configuration"
  task config: :environment do
    puts "AI Provider Configuration"
    puts "=" * 50
    puts "Provider:      #{ENV['AI_PROVIDER'] || 'not set'}"
    puts "Model:         #{ENV['AI_EMBEDDING_MODEL'] || 'not set (using default)'}"
    puts "Dimensions:    #{ENV.fetch('AI_EMBEDDING_DIMENSIONS', 1536)}"
    puts ""
    puts "API Keys:"
    puts "OpenAI:        #{ENV['OPENAI_API_KEY'].present? ? '✅ Set' : '❌ Not set'}"
    puts "Gemini:        #{ENV['GEMINI_API_KEY'].present? ? '✅ Set' : '❌ Not set'}"
    puts ""
    puts "Database:"
    puts "Clients with embeddings:  #{Client.where.not(embedding: nil).count}/#{Client.count}"
    puts "Addresses with embeddings: #{Address.where.not(embedding: nil).count}/#{Address.count}"
  end

  desc "Clear all embeddings"
  task clear_all: :environment do
    print "⚠️  This will clear all embeddings. Are you sure? (yes/no): "
    confirmation = STDIN.gets.chomp

    unless confirmation.downcase == "yes"
      puts "Operation cancelled."
      exit 0
    end

    puts "Clearing embeddings..."
    Client.update_all(embedding: nil)
    Address.update_all(embedding: nil)
    puts "✅ All embeddings cleared!"
  end
end
