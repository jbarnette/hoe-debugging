require File.join File.dirname(__FILE__), "../lib/hoe/debugging"
require 'fileutils'

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
      expect(helper.version_matches).to eq %w[ruby-1.9.3.194 ruby-1.9.3 ruby-1.9]
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

  describe "#matching_suppression_file" do
    context "there are multiple matches" do
      it "returns the best match" do
        helper = klass.new "myproj", :directory => suppressions_directory
        exact_match = File.join(suppressions_directory, "myproj_#{helper.formatted_ruby_version}.supp")
        inexact_match = File.join(suppressions_directory, "myproj_#{helper.version_matches[1]}.999999999.supp")
        FileUtils.mkdir_p suppressions_directory
        FileUtils.touch inexact_match
        FileUtils.touch exact_match
        expect(helper.matching_suppression_file).to eq exact_match
      end
    end


    context "there is one inexact match" do
      it "returns it" do
        helper = klass.new "myproj", :directory => suppressions_directory
        inexact_match = File.join(suppressions_directory, "myproj_#{helper.version_matches[1]}.999999999.supp")
        FileUtils.mkdir_p suppressions_directory
        FileUtils.touch inexact_match
        expect(helper.matching_suppression_file).to eq inexact_match
      end
    end

    context "there is one exact match" do
      it "returns it" do
        helper = klass.new "myproj", :directory => suppressions_directory
        exact_match = File.join(suppressions_directory, "myproj_#{helper.formatted_ruby_version}.supp")
        FileUtils.mkdir_p suppressions_directory
        FileUtils.touch exact_match
        expect(helper.matching_suppression_file).to eq exact_match
      end
    end

    context "there are zero matches" do
      it "returns nil" do
        helper = klass.new "myproj", :directory => suppressions_directory
        expect(helper.matching_suppression_file).to be_nil
      end
    end
  end

  describe "exit code" do
    let(:test_dir) { File.join(File.dirname(__FILE__), "files/test_project") }

    before do
      Dir.chdir test_dir do
        system "bundle install > /dev/null 2>&1"
        system "bundle exec rake compile > /dev/null 2>&1 "
      end
    end

    context "from a good run" do
      it "is zero" do
        Bundler.with_clean_env do
          Dir.chdir test_dir do
            system "bundle exec rake test:valgrind TESTOPTS='--name /notexist/' > good-run.log 2>&1"
            exitcode = $?
            expect(exitcode.success?).to(be_truthy, File.read("good-run.log"))
          end
        end
      end
    end

    context "from a bad run" do
      it "is nonzero" do
        Bundler.with_clean_env do
          Dir.chdir test_dir do
            system "bundle exec rake test:valgrind > bad-run.log 2>&1"
            exitcode = $?
            expect(exitcode.success?).to(be_falsey, File.read("bad-run.log"))
          end
        end
      end
    end
  end
end
