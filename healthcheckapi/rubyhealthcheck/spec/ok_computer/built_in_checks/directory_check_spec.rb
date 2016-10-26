require "rails_helper"

module OkComputer
  describe DirectoryCheck do
    let(:dir) { '/top_dir/subdir' }

    subject { described_class.new(dir) }

    it "is a subclass of Check" do
      subject.should be_a Check
    end

    describe "#new(directory, writable)" do
      it "requires directory" do
        expect { described_class.new(nil, true) }.to raise_error(ArgumentError)
      end
      it "remembers directory" do
        expect(subject.directory).to eq dir
      end

      it "defaults writable to true" do
        expect(subject.writable).to eq true
      end
      it "remembers writable" do
        check = described_class.new(dir, false)
        expect(check.writable).to eq false
      end
    end

    describe "#check" do
      context "when directory is readable and writable" do
        before do
          file_stat = double(File::Stat, directory?: true, readable?: true, writable?: true)
          allow(File).to receive(:exist?).with(dir).and_return(true)
          allow(File).to receive(:stat).with(dir).and_return(file_stat)
        end
        context 'desired: writable' do
          it { should be_successful }
          it { should have_message "Directory '#{dir}' is writable (as expected)." }
        end
        context 'desired: not writable' do
          subject { described_class.new(dir, false) }
          it { should_not be_successful }
          it { should have_message "Directory '#{dir}' is writable (undesired)." }
        end
      end

      context "when directory is readable but not writable" do
        before do
          file_stat = double(File::Stat, directory?: true, readable?: true, writable?: false)
          allow(File).to receive(:exist?).with(dir).and_return(true)
          allow(File).to receive(:stat).with(dir).and_return(file_stat)
        end
        context 'desired: not writable' do
          subject { described_class.new(dir, false) }
          it { should be_successful }
          it { should have_message "Directory '#{dir}' is NOT writable (as expected)." }
        end
        context 'desired: writable' do
          it { should_not be_successful }
          it { should have_message "Directory '#{dir}' is not writable." }
        end
      end

      context "when directory is not readable" do
        before do
          file_stat = double(File::Stat, directory?: true, readable?: false)
          allow(File).to receive(:exist?).with(dir).and_return(true)
          allow(File).to receive(:stat).with(dir).and_return(file_stat)
        end
        it { should_not be_successful }
        it { should have_message "Directory '#{dir}' is not readable." }
      end

      context 'when directory is not a directory' do
        before do
          file_stat = double(File::Stat, directory?: false)
          allow(File).to receive(:exist?).with(dir).and_return(true)
          allow(File).to receive(:stat).with(dir).and_return(file_stat)
        end
        it { should_not be_successful }
        it { should have_message "'#{dir}' is not a directory." }
      end

      context 'when directory does not exist' do
        before do
          allow(File).to receive(:exist?).with(dir).and_return(false)
        end
        it { should_not be_successful }
        it { should have_message "Directory '#{dir}' does not exist." }
      end
    end
  end
end
