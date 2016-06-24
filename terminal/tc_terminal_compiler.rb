require_relative "terminal_compiler"
require "test/unit"

class TestAutomata < Test::Unit::TestCase

  def setup
    @compiler = Compiler.new
    @compiler.build
  end

  def test_working
    assert_true(@compiler.analyse("hijijkkkmmmmm"))
    assert_true(@compiler.analyse("hijijkkijkmmmmm"))
    assert_true(@compiler.analyse("abcd"))
    assert_true(@compiler.analyse("abef"))
    assert_true(@compiler.analyse("nnnnn"))
    assert_true(@compiler.analyse("g"))
    assert_true(@compiler.analyse("hijijkkkmmmmm"))
  end

  def test_not_working
    assert_false(@compiler.analyse("hiji"))
    assert_false(@compiler.analyse("hijijkkijkmmmmmij"))
    assert_false(@compiler.analyse("abcdef"))
    assert_false(@compiler.analyse("abefg"))
    assert_false(@compiler.analyse("abnnnnn"))
  end
end
