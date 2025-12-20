# frozen_string_literal: true

# config/initializers/ai_provider.rb
# Configuration for AI provider (OpenAI or Gemini)

Rails.application.config.before_initialize do
  # Validate AI provider configuration
  ai_provider = ENV["AI_PROVIDER"]

  if ai_provider.present?
    unless %w[openai gemini].include?(ai_provider.downcase)
      Rails.logger.warn "Invalid AI_PROVIDER: #{ai_provider}. Must be 'openai' or 'gemini'. Defaulting to 'openai'."
      ENV["AI_PROVIDER"] = "openai"
    end

    # Validate required API keys
    case ENV["AI_PROVIDER"]&.downcase
    when "openai"
      if ENV["OPENAI_API_KEY"].blank?
        Rails.logger.error "OPENAI_API_KEY is required when AI_PROVIDER is 'openai'"
      end
    when "gemini"
      if ENV["GEMINI_API_KEY"].blank?
        Rails.logger.error "GEMINI_API_KEY is required when AI_PROVIDER is 'gemini'"
      end
    end

    # Validate embedding dimensions
    dimensions = ENV.fetch("AI_EMBEDDING_DIMENSIONS", "1536").to_i
    unless dimensions.positive?
      Rails.logger.warn "Invalid AI_EMBEDDING_DIMENSIONS: #{dimensions}. Must be > 0. Defaulting to 1536."
      ENV["AI_EMBEDDING_DIMENSIONS"] = "1536"
    end

    # Log configuration
    Rails.logger.info "AI Provider configured:"
    Rails.logger.info "  Provider: #{ENV['AI_PROVIDER']}"
    Rails.logger.info "  Model: #{ENV.fetch('AI_EMBEDDING_MODEL', 'default')}"
    Rails.logger.info "  Dimensions: #{ENV.fetch('AI_EMBEDDING_DIMENSIONS', '1536')}"
  end
end
