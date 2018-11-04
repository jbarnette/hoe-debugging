require_relative "spec_helper.rb"

describe Hoe::Debugging::ValgrindHelper do
  let(:logfile)  { File.join File.dirname(__FILE__), "files/sample.log" }
  let(:suppfile) { File.join File.dirname(__FILE__), "files/sample.supp" }
  let(:klass)    { Hoe::Debugging::ValgrindHelper }

  let(:suppressions_directory) { "tmp/suppressions" }
  before { FileUtils.rm_rf suppressions_directory }

  describe "#initialize" do
    it "requires a project_name argument" do
      expect { klass.new }.to raise_error ArgumentError
    end
  end

  describe "#directory" do
    it { expect(klass.new("myproj")                     .directory).to eq "suppressions" }
    it { expect(klass.new("myproj", :directory => "foo").directory).to eq "foo" }
  end

  describe "#project_name" do
    it { expect(klass.new("myproj").project_name).to eq "myproj" }
  end

  describe "#version_matches" do
    it "returns possible suppression file matches in order of specificity" do
      helper = klass.new "myproj"
      allow(helper).to receive(:formatted_ruby_version) { "ruby-1.9.3.194" }
      expect(helper.version_matches).to eq %w[ruby-1.9.3.194 ruby-1.9.3 ruby-1.9 ruby-1]
    end
  end

  describe "#parse_suppressions_from" do
    it "generates a de-duped set of suppressions" do
      helper = klass.new "myproj"
      suppressions = helper.parse_suppressions_from logfile

      expected = File.read suppfile

      expect(suppressions).to eq expected
    end
  end

  describe "#save_suppressions_from" do
    it "saves a file simply containing the ruby" do
      helper = klass.new "myproj", :directory => suppressions_directory
      actual_file = helper.save_suppressions_from logfile
      expect(actual_file).to match(/myproj_ruby-.*\.supp/)

      actual = File.read actual_file
      expected = File.read suppfile
      expect(actual).to eq expected
    end
  end

  describe "#matching_suppression_files" do
    context "there are multiple matches" do
      it "returns all matches" do
        helper = klass.new "myproj", :directory => suppressions_directory
        matching_files = helper.version_matches.map do |version_match|
          File.join(suppressions_directory, "myproj_#{version_match}.supp")
        end
        inexact_match = File.join(suppressions_directory, "myproj_#{helper.version_matches[1]}.99999.supp")
        all_files = matching_files + [inexact_match]

        FileUtils.mkdir_p suppressions_directory
        all_files.each { |f| FileUtils.touch f }

        expect(helper.matching_suppression_files).to eq(matching_files)
      end

      it "returns all matches even with trailing desc" do
        helper = klass.new "myproj", :directory => suppressions_directory
        matching_files = helper.version_matches.map do |version_match|
          File.join(suppressions_directory, "myproj_#{version_match}_foo.supp")
        end
        inexact_match = File.join(suppressions_directory, "myproj_#{helper.version_matches[1]}.99999_foo.supp")
        all_files = matching_files + [inexact_match]

        FileUtils.mkdir_p suppressions_directory
        all_files.each { |f| FileUtils.touch f }

        expect(helper.matching_suppression_files).to eq(matching_files)
      end
    end

    context "there are zero matches" do
      it "returns nil" do
        helper = klass.new "myproj", :directory => suppressions_directory
        expect(helper.matching_suppression_files).to eq([])
      end
    end
  end
end
