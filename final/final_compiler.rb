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

  def tokenize(file)
    file = File.new(file, "r")
    line_number = 1
    tokens = []
    while (line = file.gets)
      while line.length > 0 do
        if line[0] == " " || line[0] == "\n" || line[0] == "\t"
          line = line[1..-1]
        elsif /[[:lower:]]/.match(line[0])
          word = line.partition(" ").first
          if word[-1] == "\n"
            tokens << [["",word[0..-2],""].join("\""),line_number]
          else
            tokens << [["",word[0..-1],""].join("\""),line_number]
          end
          line = line.partition(" ").last
        elsif line[0] == ">" || line[0] == "<" || line[0] == "!"
          if line[1] == "="
            token = ["\""<<line[0]<<line[1]<<"\"",line_number]
            tokens << token
            line = line[2..-1]
          else
            tokens << [["",line[0],""].join("\""),line_number]
            line = line[1..-1]
          end
        elsif /[[:upper:]]/.match(line[0])
          tokens << ["\"character\"",line_number]
          line = line[1..-1]
        elsif /[[:digit:]]/.match(line[0])
          tokens << ["\"number\"",line_number]
          line = line[1..-1]
        else
          tokens << [["",line[0],""].join("\""),line_number]
          line = line[1..-1]
        end
      end
      line_number += 1
    end
    tokens
  end

  def build
    $analyser = Analyser.new
    $analyser.build("final.txt")
  end

  def analyse(codefile)
    puts "Analysing Code"
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
