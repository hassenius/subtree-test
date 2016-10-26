require "rails_helper"

# Stubbing the constant out; will exist in apps which have Neo4j loaded
module Neo4j
  class Session
  end
end

module Faraday
  module Error
    class ConnectionFailed < StandardError; end
  end
end

module OkComputer
  describe Neo4jCheck do
    it "is a subclass of Check" do
      subject.should be_a Check
    end

    context "#check" do
      context "with a successful connection" do
        before do
          allow(Neo4j::Session).to receive_message_chain("current.connection.head.success?") { true }

          allow(Neo4j::Session).to receive_message_chain("current.connection.url_prefix.to_s") { "localhost:7474" }
        end

        it { should be_successful }
        it { should have_message "Connected to neo4j on localhost:7474" }
      end

      context "with an unsuccessful connection" do
        let(:error_message) { "connection refused: localhost:7474" }
        let(:error) { Faraday::Error::ConnectionFailed.new(error_message) }

        before do
          allow(Neo4j::Session).to receive_message_chain("current.connection.head.success?").and_raise(error)
        end

        it {should_not be_successful }
        it {should have_message "Error: #{error_message}" }
      end
    end
  end
end
