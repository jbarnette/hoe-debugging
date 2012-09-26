require File.join File.dirname(__FILE__), "../lib/hoe/debugging"

describe Hoe::Debugging::ValgrindHelper do
  let(:logfile)  { File.join File.dirname(__FILE__), "files/sample.log" }
  let(:suppfile) { File.join File.dirname(__FILE__), "files/sample.supp" }
  let(:klass)    { Hoe::Debugging::ValgrindHelper }

  let(:suppressions_directory) { "tmp/suppressions" }
  before { FileUtils.rm_rf suppressions_directory }

  describe "#initialize" do
    it "requires a project_name argument" do
      proc { klass.new }.should raise_error ArgumentError
    end
  end

  describe "#directory" do
    it { klass.new("myproj")                     .directory.should == "suppressions" }
    it { klass.new("myproj", :directory => "foo").directory.should == "foo" }
  end

  describe "#project_name" do
    it { klass.new("myproj").project_name.should == "myproj" }
  end

  describe "#version_matches" do
    it "returns possible suppression file matches in order of specificity" do
      helper = klass.new "myproj"
      helper.stub(:formatted_ruby_version) { "ruby-1.9.3.194" }
      helper.version_matches.should == %w[ruby-1.9.3.194 ruby-1.9.3 ruby-1.9]
    end
  end

  describe "#parse_suppressions_from" do
    it "generates a de-duped set of suppressions" do
      helper = klass.new "myproj"
      suppressions = helper.parse_suppressions_from logfile

      expected = File.read suppfile

      suppressions.should == expected
    end
  end

  describe "#save_suppressions_from" do
    it "saves a file simply containing the ruby" do
      helper = klass.new "myproj", :directory => suppressions_directory
      actual_file = helper.save_suppressions_from logfile
      actual_file.should =~ /myproj_ruby-.*\.supp/

      actual = File.read actual_file
      expected = File.read suppfile
      actual.should == expected
    end
  end

  describe "#matching_suppression_file" do
    context "there are multiple matches" do
      it "returns the best match" do
        helper = klass.new "myproj", :directory => suppressions_directory
        exact_match = File.join(suppressions_directory, "myproj_#{helper.formatted_ruby_version}.supp")
        inexact_match = File.join(suppressions_directory, "myproj_#{helper.version_matches[1]}.999999999.supp")
        FileUtils.mkdir_p suppressions_directory
        FileUtils.touch inexact_match
        FileUtils.touch exact_match
        helper.matching_suppression_file.should == exact_match
      end
    end


    context "there is one inexact match" do
      it "returns it" do
        helper = klass.new "myproj", :directory => suppressions_directory
        inexact_match = File.join(suppressions_directory, "myproj_#{helper.version_matches[1]}.999999999.supp")
        FileUtils.mkdir_p suppressions_directory
        FileUtils.touch inexact_match
        helper.matching_suppression_file.should == inexact_match
      end
    end

    context "there is one exact match" do
      it "returns it" do
        helper = klass.new "myproj", :directory => suppressions_directory
        exact_match = File.join(suppressions_directory, "myproj_#{helper.formatted_ruby_version}.supp")
        FileUtils.mkdir_p suppressions_directory
        FileUtils.touch exact_match
        helper.matching_suppression_file.should == exact_match
      end
    end

    context "there are zero matches" do
      it "returns nil" do
        helper = klass.new "myproj", :directory => suppressions_directory
        helper.matching_suppression_file.should == nil
      end
    end
  end
end
