require_relative '../analyser'

class Compiler

  def puts_green(string)
    puts "\e[32m#{string}\e[0m"
  end

  def puts_red(string)
    puts "\e[31m#{string}\e[0m"
  end

  def cpy_list(list)
    new_list = Array.new
    list.map { |e| new_list << e }
    new_list
  end

  def tokenize(string)
    splitted = string.split("")
    ready = []
    splitted.map { |s| ready << ["\""<<s<<"\"",0] }
    ready
  end

  def build
    $analyser = Analyser.new
    $analyser.build("expression.txt")
  end

  def analyse(string)
    puts "Analysing Code"
    codefile = string
    tokens = tokenize(codefile)
    result = $analyser.syntactic(cpy_list(tokens))
    if result
      puts_green "Syntax is correct"
    else
      puts_red "Syntax error"
    end
    result
  end

end
