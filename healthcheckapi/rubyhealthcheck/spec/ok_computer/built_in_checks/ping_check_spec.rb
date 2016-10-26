require "rails_helper"

module OkComputer
  describe PingCheck do
    let(:host) { 'localhost' }
    let(:port) { '666666' }

    subject { described_class.new(host, port) }

    it "is a subclass of Check" do
      subject.should be_a Check
    end

    describe "#new(host, port, request_timeout)" do
      it "requires host" do
        expect { described_class.new(nil, port) }.to raise_error(ArgumentError)
      end
      it "remembers host" do
        expect(subject.host).to eq(host)
      end

      it "requires port" do
        expect { described_class.new(host) }.to raise_error(ArgumentError)
      end
      it "remembers port" do
        expect(subject.port).to eq(port)
      end

      it "defaults request_timeout to 5 seconds" do
        expect(subject.request_timeout).to eq(5)
      end
      it "remembers request_timeout" do
        check = described_class.new(host, port, 10)
        expect(check.request_timeout).to eq(10)
      end
      it "coerces request_timeout to an integer" do
        check = described_class.new(host, port, "8")
        expect(check.request_timeout).to eq(8)
      end
    end

    describe "#check" do
      context "when the connection is successful" do
        before do
          allow(subject).to receive(:tcp_socket_request).and_return("foo")
        end

        it { should be_successful }
        it { should have_message "Ping check to #{host}:#{port} successful" }
      end

      context "when the connection fails" do
        let(:error_message) { "Error message" }

        before do
          allow(subject).to receive(:tcp_socket_request).and_raise(PingCheck::ConnectionFailed, error_message)
        end

        it { should_not be_successful }
        it { should have_message "Error: '#{error_message}'" }
      end
    end

    describe "#tcp_socket_request" do
      let(:tcp_socket) { double(TCPSocket) }
      let(:error_message) { "Error message" }

      context "when the connection is successful" do
        before do
          allow(tcp_socket).to receive(:close)
          allow(TCPSocket).to receive(:new).and_return(tcp_socket)
        end

        it "doesn't raise an error" do
          expect { subject.send(:tcp_socket_request) }.not_to raise_error
        end
      end

      context "when the connection is refused" do
        before do
          allow(TCPSocket).to receive(:new).and_raise(Errno::ECONNREFUSED)
        end

        it "raises a ConnectionFailed error" do
          exp_message = /#{host} is not accepting connections on port #{port}.*Connection refused/
          expect { subject.send(:tcp_socket_request) }.to raise_error(PingCheck::ConnectionFailed, exp_message)
        end
      end

      context 'when there is a SocketError' do
        before do
          allow(TCPSocket).to receive(:new).and_raise(SocketError)
        end

        it "raises a ConnectionFailed error" do
          exp_message = /connection to #{host} on port #{port} failed with.*SocketError/
          expect { subject.send(:tcp_socket_request) }.to raise_error(PingCheck::ConnectionFailed, exp_message)
        end
      end

      context 'when there is a TimeoutError' do
        before do
          allow(TCPSocket).to receive(:new).and_raise(TimeoutError)
        end

        it "raises a ConnectionFailed error" do
          exp_message = /#{host} did not respond on port #{port} within #{subject.request_timeout} seconds: Timeout::Error/
          expect { subject.send(:tcp_socket_request) }.to raise_error(PingCheck::ConnectionFailed, exp_message)
        end
      end
    end
  end
end
