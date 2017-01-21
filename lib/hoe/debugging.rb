require 'rbconfig'

class Hoe #:nodoc:

  # Whee, stuff to help when your codes are b0rked. Tasks provided:
  #
  # * <tt>test:gdb</tt>
  # * <tt>test:valgrind</tt>
  # * <tt>test:valgrind:mem</tt>
  # * <tt>test:valgrind:mem0</tt>

  module Debugging
    VERSION = "1.3.0" #:nodoc:

    ##
    # The exit code of valgrind when it detects an error.
    ERROR_EXITCODE = 42 # the answer to life, the universe, and segfaulting.

    ##
    # Optional: Used to add flags to GDB. [default: <tt>[]</tt>]

    attr_accessor :gdb_options

    ##
    # Optional: Used to add flags to valgrind. [default:
    # <tt>%w(--num-callers=50 --error-limit=no --partial-loads-ok=yes
    # --undef-value-errors=no)</tt>]

    attr_accessor :valgrind_options

    def initialize_debugging #:nodoc:
      self.gdb_options = []

      self.valgrind_options = ["--num-callers=50",
                               "--error-limit=no",
                               "--partial-loads-ok=yes",
                               "--undef-value-errors=no",
                               "--error-exitcode=#{ERROR_EXITCODE}",
                              ]
    end

    def hoe_debugging_ruby
      # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/151376
      @ruby ||= File.join(RbConfig::CONFIG["bindir"], (RbConfig::CONFIG["RUBY_INSTALL_NAME"] + RbConfig::CONFIG["EXEEXT"]))
    end

    def hoe_debugging_make_test_cmd
      cmd = []
      if File.directory? "spec"
        cmd << "-S rspec"
        cmd << (ENV['FILTER'] || ENV['TESTOPTS'])
      else
        cmd << make_test_cmd
      end
      cmd.join(' ')
    end

    def hoe_debugging_command
      "#{hoe_debugging_ruby} #{hoe_debugging_make_test_cmd}"
    end

    def hoe_debugging_run_valgrind command, cmdline_options=[]
      sh "#{hoe_debugging_valgrind_helper.valgrind} #{cmdline_options.join(' ')} #{command}"
    end

    def hoe_debugging_check_for_suppression_file options
      if suppression_file = hoe_debugging_valgrind_helper.matching_suppression_file
        puts "NOTICE: using valgrind suppressions in #{suppression_file.inspect}"
        options << "--suppressions=#{suppression_file}"
      end
    end

    def hoe_debugging_valgrind_helper
      @valgrind_helper ||= ValgrindHelper.new name
    end

    def define_debugging_tasks #:nodoc:
      desc "Run the test suite under GDB."
      task "test:gdb" do
        sh "gdb #{gdb_options.join ' '} --args #{hoe_debugging_command}"
      end

      desc "Run the test suite under Valgrind."
      task "test:valgrind" do
        vopts = valgrind_options
        hoe_debugging_check_for_suppression_file vopts
        hoe_debugging_run_valgrind hoe_debugging_command, vopts
      end

      desc "Run the test suite under Valgrind with memory-fill."
      task "test:valgrind:mem" do
        vopts = valgrind_options + ["--freelist-vol=100000000", "--malloc-fill=6D", "--free-fill=66"]
        hoe_debugging_check_for_suppression_file vopts
        hoe_debugging_run_valgrind hoe_debugging_command, vopts
      end

      desc "Run the test suite under Valgrind with memory-zero."
      task "test:valgrind:mem0" do
        vopts = valgrind_options + ["--freelist-vol=100000000", "--malloc-fill=00", "--free-fill=00"]
        hoe_debugging_check_for_suppression_file vopts
        hoe_debugging_run_valgrind hoe_debugging_command, vopts
      end

      desc "Generate a valgrind suppression file for your test suite."
      task "test:valgrind:suppression" do
        vopts = valgrind_options + ["--gen-suppressions=all"]
        Tempfile.open "hoe_debugging_valgrind_suppression_log" do |logfile|
          hoe_debugging_run_valgrind "#{hoe_debugging_ruby} #{hoe_debugging_make_test_cmd} 2> #{logfile.path}", vopts
          hoe_debugging_valgrind_helper.save_suppressions_from logfile.path
        end
      end
    end

    class ValgrindHelper
      DEFAULT_DIRECTORY_NAME = "suppressions"

      attr_accessor :directory, :project_name

      def initialize project_name, options={}
        @project_name = project_name
        @directory    = options[:directory] || DEFAULT_DIRECTORY_NAME
      end

      def formatted_ruby_version
        engine = if defined?(RUBY_DESCRIPTION) && RUBY_DESCRIPTION =~ /Ruby Enterprise Edition/
                   "ree"
                 else
                   defined?(RUBY_ENGINE) ? RUBY_ENGINE : "ruby"
                 end
        %Q{#{engine}-#{RUBY_VERSION}.#{RUBY_PATCHLEVEL}}
      end

      def version_matches
        matches = [formatted_ruby_version]
        matches << formatted_ruby_version.split(".")[0,3].join(".")
        matches << formatted_ruby_version.split(".")[0,2].join(".")
        matches
      end

      def parse_suppressions_from logfile_name
        suppressions = []
        File.open logfile_name do |logfile|
          suppression = nil
          while ! logfile.eof? do
            line = logfile.readline
            if suppression.nil?
              if line =~ /\<insert_a_suppression_name_here\>/
                suppression = "{\n"
                suppression << line
              end
            else
              suppression << line
              if line =~ /^\}$/
                suppressions << suppression
                suppression = nil
              end
            end
          end
        end
        suppressions.uniq.join
      end

      def save_suppressions_from logfile, options={}
        ensure_directory_exists
        suppressions = parse_suppressions_from logfile
        filename = File.join directory, "#{project_name}_#{formatted_ruby_version}.supp"
        File.open(filename, "w") { |out| out.write suppressions }
        filename
      end

      def matching_suppression_file
        version_matches.each do |version_string|
          matches = Dir[File.join(directory, "#{project_name}_#{version_string}*.supp")]
          return matches[0] if matches[0]
        end
        nil
      end

      def valgrind
        # note that valgrind will generally crap out on rubies >= 2.1
        # unless we increase the max stack size beyond the default
        "ulimit -s unlimited && valgrind"
      end

      private

      def ensure_directory_exists
        return if File.directory? directory
        FileUtils.mkdir_p directory
        File.open(File.join(directory, "README.txt"), "w") do |readme|
          readme.puts "This directory contains valgrind suppression files generated by the hoe-debugging gem."
        end
      end
    end
  end
end
