# frozen_string_literal: true

class ProcessUploadJob < ApplicationJob
  queue_as :default

  def perform(upload_id)
    upload = Upload.find(upload_id)
    upload.process
  end
end
