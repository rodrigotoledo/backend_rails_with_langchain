# frozen_string_literal: true

class Upload < ApplicationRecord
  belongs_to :client

  has_one_attached :file

  validates :context, presence: true
  validates :processors, presence: true

  def process
    processors.each do |processor_name|
      processor_class = processor_name.constantize
      processor = processor_class.new(file)
      # Aqui pode chamar um método, como process_info
      # Por enquanto, apenas logar
      Rails.logger.info "Processing with #{processor_name}: #{processor.process_info if processor.respond_to?(:process_info)}"
    end
  end
end
