# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "vcr"
require "webmock/minitest"

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Stub OpenAI embeddings for tests
    setup do
      stub_request(:post, "https://api.openai.com/v1/embeddings")
        .to_return(status: 200, body: {
          data: [{ embedding: [0.1] * 1536 }],
          usage: { prompt_tokens: 10, total_tokens: 10 }
        }.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    # Add more helper methods to be used by all tests here...
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
