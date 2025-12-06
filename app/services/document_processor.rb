# frozen_string_literal: true

require "google/genai"
class DocumentProcessor
  def initialize(document)
    @document = document
    @client = Google::Genai::Client.new do |config|
      config.api_key = ENV["GEMINI_API_KEY"]
    end
  end

  def process_info
    return nil unless @document.attached?

    # Download the file content
    content = @document.download

    # Create a temp file
    temp_file = Tempfile.new([ "document", File.extname(@document.filename.to_s) ])
    temp_file.binmode
    temp_file.write(content)
    temp_file.rewind

    # Upload to Gemini
    file = @client.files.upload(file: temp_file.path)
    prompt = "Extract all the text from this document. Return only the extracted text, nothing else."

    # Use the model to extract text
    response = @client.models.generate_content(
      model: "gemini-2.5-flash",
      contents: [ prompt, file ])

    # Clean up
    temp_file.close
    temp_file.unlink
    # @client.delete_file(file.name) # Optional

    response.text
  rescue => e
    Rails.logger.error "Error extracting text with Gemini: #{e.message}"
    nil
  end
end
