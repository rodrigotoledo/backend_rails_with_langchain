# frozen_string_literal: true

# app/services/ai_embedding_service.rb
# Generic AI embedding service that supports multiple providers
class AiEmbeddingService
  class UnsupportedProviderError < StandardError; end
  class EmbeddingError < StandardError; end

  def initialize(provider: nil)
    @provider = provider || ENV.fetch("AI_PROVIDER", "openai")
    @client = build_client
  end

  # Generate embeddings for a given text
  # @param text [String] The text to generate embeddings for
  # @return [Array<Float>] The embedding vector
  def embed(text)
    case @provider
    when "openai"
      embed_with_openai(text)
    when "gemini"
      embed_with_gemini(text)
    else
      raise UnsupportedProviderError, "Provider '#{@provider}' is not supported"
    end
  rescue => e
    Rails.logger.error("Embedding error with #{@provider}: #{e.message}")
    raise EmbeddingError, "Failed to generate embedding: #{e.message}"
  end

  # Generate embeddings for multiple texts in batch
  # @param texts [Array<String>] Array of texts to generate embeddings for
  # @return [Array<Array<Float>>] Array of embedding vectors
  def embed_batch(texts)
    texts.map { |text| embed(text) }
  end

  # Get the dimensions for the current model
  # @return [Integer] The embedding dimensions
  def dimensions
    ENV.fetch("AI_EMBEDDING_DIMENSIONS", 1536).to_i
  end

  # Get the current embedding model name
  # @return [String] The model name
  def model_name
    ENV.fetch("AI_EMBEDDING_MODEL", default_model)
  end

  private

  def build_client
    case @provider
    when "openai"
      require "openai"
      OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
    when "gemini"
      require "gemini-ai"
      Gemini.new(
        credentials: {
          service: "generative-language-api",
          api_key: ENV.fetch("GEMINI_API_KEY")
        },
        options: { model: model_name, server_sent_events: true }
      )
    else
      raise UnsupportedProviderError, "Provider '#{@provider}' is not supported"
    end
  end

  def embed_with_openai(text)
    response = @client.embeddings(
      parameters: {
        model: model_name,
        input: text
      }
    )

    response.dig("data", 0, "embedding")
  end

  def embed_with_gemini(text)
    response = @client.embed_content(
      contents: { text: text }
    )

    response.dig("embedding", "values")
  end

  def default_model
    case @provider
    when "openai"
      "text-embedding-3-small"
    when "gemini"
      "text-embedding-004"
    else
      "text-embedding-3-small"
    end
  end
end
