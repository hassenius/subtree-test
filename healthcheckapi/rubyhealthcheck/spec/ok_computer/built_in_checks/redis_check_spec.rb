require "rails_helper"

class Redis
  def initialize(config)
  end
end

module OkComputer
  describe RedisCheck do
    let(:redis_config) do
      { url: "http://localhost:6379" }
    end

    subject { described_class.new(redis_config) }

    it "is a subclass of Check" do
      subject.should be_a Check
    end

    describe "#new(redis_config)" do
      it "requires a hash with redis configuration" do
        expect { described_class.new }.to raise_error(ArgumentError)
      end

      it "stores the configuration" do
        expect(described_class.new(redis_config).redis_config).to eq(redis_config)
      end
    end

    describe "#redis" do
      it "uses the redis_config" do
        expect(Redis).to receive(:new).with(redis_config)
        subject.redis
      end
    end

    describe "#check" do
      context "when the connection is successful" do
        before do
          subject.stub(:redis_info).and_return(redis_info)
        end

        let(:redis_info) do
          {
            "used_memory_human" => "1003.84K",
            "uptime_in_seconds" => "272",
            "connected_clients" => "2"
          }
        end

        it { should be_successful }
        it { should have_message "Connected to redis, 1003.84K used memory, uptime 272 secs, 2 connected client(s)" }
      end

      context "when the connection fails" do
        let(:error_message) { "Error message" }

        before do
          subject.stub(:redis_info).and_raise(RedisCheck::ConnectionFailed, error_message)
        end

        it { should_not be_successful }
        it { should have_message "Error: '#{error_message}'" }
      end
    end

    describe "#redis_info" do
      before do
        subject.stub(:redis) { redis }
      end

      context "when the connection is successful" do
        let(:redis) do
          double("Redis", info: redis_info)
        end

        let(:redis_info) do
          {
            "used_memory_human" => "1003.84K",
            "uptime_in_seconds" => "272",
            "connected_clients" => "2"
          }
        end

        it "returns a hash of the Redis INFO command" do
          expect(subject.redis_info).to eq(redis_info)
        end
      end

      context "when the connection fails" do
        let(:redis) { double("Redis") }
        before do
          redis.stub(:info) { fail Errno::ECONNREFUSED }
        end

        it "raises a ConnectionFailed error" do
          expect { subject.redis_info }.to raise_error(RedisCheck::ConnectionFailed)
        end
      end
    end
  end
end
