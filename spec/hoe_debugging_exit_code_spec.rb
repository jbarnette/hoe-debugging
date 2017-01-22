require_relative "spec_helper.rb"

describe "exit code" do
  def sh command
    Rake.sh command, verbose: false
  end

  let(:test_dir) { File.join(File.dirname(__FILE__), "files/test_project") }

  before do
    Bundler.with_clean_env do
      Dir.chdir test_dir do
        sh "gem install bundler > #{logfile} 2>&1"
        sh "bundle install >> #{logfile} 2>&1"
        sh "bundle exec rake compile >> #{logfile} 2>&1"
      end
    end
  end

  context "from a good run" do
    let(:logfile) { "good-run.log" }
    it "is zero" do
      Bundler.with_clean_env do
        Dir.chdir test_dir do
          system "bundle exec rake test:valgrind TESTOPTS='--name /notexist/' >> #{logfile} 2>&1"
          exitcode = $?
          expect(exitcode.success?).to(be_truthy, File.read(logfile))
        end
      end
    end
  end

  context "from a bad run" do
    let(:logfile) { "good-run.log" }
    it "is nonzero" do
      Bundler.with_clean_env do
        Dir.chdir test_dir do
          system "bundle exec rake test:valgrind >> #{logfile} 2>&1"
          exitcode = $?
          expect(exitcode.success?).to(be_falsey, File.read(logfile))
        end
      end
    end
  end
end
