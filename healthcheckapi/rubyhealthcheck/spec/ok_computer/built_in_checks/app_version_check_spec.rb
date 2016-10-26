require "rails_helper"

module OkComputer
  describe AppVersionCheck do
    it "is a subclass of Check" do
      subject.should be_a Check
    end

    context "#check" do
      let(:version) { "sha" }

      context "when able to deterimine the version" do
        before do
          subject.should_receive(:version).and_return(version)
        end

        it { should be_successful }
        it { should have_message "Version: #{version}" }
      end

      context "when unable to determine the version" do
        before do
          subject.should_receive(:version).
            and_raise(AppVersionCheck::UnknownRevision)
        end

        it { should_not be_successful }
        it { should have_message "Unable to determine version" }
      end
    end

    context "#version" do
      let(:version) { "version" }
      let(:revision_path) { Rails.root.join("REVISION") }

      context "with the SHA environment variable set" do
        around(:example) do |example|
          with_env("SHA" => version) do
            example.run
          end
        end

        it "returns the contents of SHA" do
          expect(subject.version).to eq(version)
        end
      end

      context "with a REVISION file at the root of the app directory" do
        around(:example) do |example|
          with_env("SHA" => nil) do
            example.run
          end
        end

        before do
          File.should_receive(:exist?).with(revision_path).and_return(true)
          File.should_receive(:read).with(revision_path).and_return("#{version}\n")
        end

        it "returns the contents of the file" do
          expect(subject.version).to eq(version)
        end
      end

      context "without these" do
        around(:example) do |example|
          with_env("SHA" => nil) do
            example.run
          end
        end

        before do
          File.should_receive(:exist?).with(revision_path).and_return(false)
        end

        it "raises an exception" do
          expect {
            subject.version
          }.to raise_error(AppVersionCheck::UnknownRevision)
        end
      end
    end
  end
end
