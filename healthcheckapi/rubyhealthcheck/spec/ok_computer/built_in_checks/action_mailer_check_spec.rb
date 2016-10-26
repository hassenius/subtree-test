require "rails_helper"

module OkComputer
  describe ActionMailerCheck do
    before do
      class ActionMailerSubclass < ActionMailer::Base
        smtp_settings[:address] = 'mail.example.com'
        smtp_settings[:port] = 666
      end
    end

    subject { described_class.new }

    it "is a subclass of Check" do
      subject.should be_a Check
    end

    describe "#new(class, timeout)" do
      it 'defaults klass to ActionMailer::Base' do
        expect(subject.klass).to eq ActionMailer::Base
      end
      it "remembers klass" do
        amcheck = described_class.new(OkComputer::ActionMailerSubclass)
        expect(amcheck.klass).to eq OkComputer::ActionMailerSubclass
      end

      it 'defaults timeout to 5' do
        expect(subject.timeout).to eq 5
      end
      it "remembers timeout" do
        amcheck = described_class.new(ActionMailer::Base, 27)
        expect(amcheck.timeout).to eq 27
      end

      it "sets host to klass.smtp_settings[:address]" do
        amcheck = described_class.new(ActionMailerSubclass)
        expect(amcheck.host).to eq 'mail.example.com'
        expect(amcheck.host).to eq OkComputer::ActionMailerSubclass.smtp_settings[:address]
      end

      it 'sets port to klass.smtp_settings[:port]' do
        amcheck = described_class.new(ActionMailerSubclass)
        expect(amcheck.port).to eq 666
        expect(amcheck.port).to eq ActionMailerSubclass.smtp_settings[:port]
      end
      it "sets port to 25 if no klass.smtp_settings[:port]" do
        am = ActionMailer::Base.send(:new)
        am.smtp_settings[:port] = nil
        amcheck = described_class.new(am)
        expect(amcheck.port).to eq 25
      end
    end

    describe '#check' do
      context "when mailer is accepting connections" do
        before do
          ActionMailer::Base.smtp_settings[:address] = 'localhost'
          ActionMailer::Base.smtp_settings[:port] = 25
          TCPSocket.should_receive(:new).with('localhost', 25).and_return(double(:socket, :close => true))
        end

        it { should be_successful }
        it { should have_message "ActionMailer::Base check to localhost:25 successful" }
      end

      context "when mailer does not accept connection" do
        let(:amcheck) { described_class.new(ActionMailerSubclass) }
        it 'is not successful' do
          expect(amcheck).to receive(:tcp_socket_request).and_raise(Errno::ECONNREFUSED)
          expect(amcheck).not_to be_successful
        end
        it 'has expected failure message' do
          expect(amcheck).to receive(:tcp_socket_request).and_raise(Errno::ECONNREFUSED)
          expect(amcheck).to have_message "OkComputer::ActionMailerSubclass at mail.example.com:666 is not accepting connections: 'Connection refused'"
        end
      end
    end
  end
end
