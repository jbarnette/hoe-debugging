gem "minitest"
require "minitest/autorun"
require "test_project"
require "test_project.so"

class TestTestProject < Minitest::Test
  def test_good
    STDERR.puts "MIKE: running the test"
    Hoedebuggingtest.bad_method
  end
end
