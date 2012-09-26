require 'rbconfig'

class Hoe #:nodoc:

  # Whee, stuff to help when your codes are b0rked. Tasks provided:
  #
  # * <tt>test:gdb</tt>
  # * <tt>test:valgrind</tt>
  # * <tt>test:valgrind:mem</tt>
  # * <tt>test:valgrind:mem0</tt>

  module Debugging
    VERSION = "1.0.5" #:nodoc:

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
                               "--undef-value-errors=no"]
    end

    def hoe_debugging_ruby
      # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/151376
      @ruby ||= File.join(Config::CONFIG["bindir"], (Config::CONFIG["RUBY_INSTALL_NAME"] + Config::CONFIG["EXEEXT"]))
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
      sh "valgrind #{cmdline_options.join(' ')} #{command}"
    end

    def define_debugging_tasks #:nodoc:
      desc "Run the test suite under GDB."
      task "test:gdb" do
        sh "gdb #{gdb_options.join ' '} --args #{hoe_debugging_command}"
      end

      desc "Run the test suite under Valgrind."
      task "test:valgrind" do
        vopts = valgrind_options
        hoe_debugging_run_valgrind hoe_debugging_command, vopts
      end

      desc "Run the test suite under Valgrind with memory-fill."
      task "test:valgrind:mem" do
        vopts = valgrind_options + ["--freelist-vol=100000000", "--malloc-fill=6D", "--free-fill=66"]
        hoe_debugging_run_valgrind hoe_debugging_command, vopts
      end

      desc "Run the test suite under Valgrind with memory-zero."
      task "test:valgrind:mem0" do
        vopts = valgrind_options + ["--freelist-vol=100000000", "--malloc-fill=00", "--free-fill=00"]
        hoe_debugging_run_valgrind hoe_debugging_command, vopts
      end
    end
  end
end
