require "rails_helper"

module OkComputer
  describe GenericCacheCheck do
    it "is a Check" do
      subject.should be_a Check
    end

    context "#check" do
      let(:value) { "asdf" }
      let(:incorrect_value) { "qwerty" }
      let(:error) { StandardError.new("connection failure") }

      context "with a successful connection" do
        before do
          subject.should_receive(:test_value).and_return(value)
          Rails.cache.should_receive(:write)
          Rails.cache.should_receive(:read).and_return(value)
        end

        it { should be_successful }
        it { should have_message "Able to read and write via File store" }
      end

      context "with a failed write" do
        before do
          subject.should_receive(:test_value).and_return(value)
          Rails.cache.should_receive(:write).and_raise(error)
        end

        it { should_not be_successful }
        it { should have_message "Connection failure: #{error}" }
      end

      context "with a failed read" do
        before do
          subject.should_receive(:test_value).and_return(value)
          Rails.cache.should_receive(:write)
          Rails.cache.should_receive(:read).and_raise(error)
        end

        it { should_not be_successful }
        it { should have_message "Connection failure: #{error}" }
      end

      context "with a mismatched result from the read" do
        before do
          subject.should_receive(:test_value).and_return(value)
          Rails.cache.should_receive(:write)
          Rails.cache.should_receive(:read).and_return(incorrect_value)
        end

        it { should_not be_successful }
        it { should have_message "Value read from the cache does not match the value written" }
      end
    end
  end
end
