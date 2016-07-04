require_relative "expression_compiler"
require "test/unit"

class TestAutomata < Test::Unit::TestCase

  def setup
    @compiler = Compiler.new
    @compiler.build
  end

  def test_working
    assert_true(@compiler.analyse("n"))
    assert_true(@compiler.analyse("<>"))
    assert_true(@compiler.analyse("<n>"))
    assert_true(@compiler.analyse("<<n>>"))
    assert_true(@compiler.analyse("<<<n>>>"))
    assert_true(@compiler.analyse("<<<<n>>>>"))
    assert_true(@compiler.analyse("<<<<<n>>>>>"))
    assert_true(@compiler.analyse("n*n"))
    assert_true(@compiler.analyse("n-n"))
    assert_true(@compiler.analyse("n-n-n"))
    assert_true(@compiler.analyse("<>-n"))
    assert_true(@compiler.analyse("n-<n*<n-n>>"))
    assert_true(@compiler.analyse("n*n-<n*<n-n>*<>>"))
  end

  def test_not_working
    assert_false(@compiler.analyse("<<n>"))
    assert_false(@compiler.analyse("n>"))
    assert_false(@compiler.analyse("<n*-n>"))
    assert_false(@compiler.analyse("-n"))
  end
end
