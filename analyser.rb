require_relative 'automata'
require_relative 'token'

class Analyser

  def build(file)
    check_wirth(file)
    puts "Building Compiler"
    tokenlines = reduce_wirth(file) ##fix
    $machines = Hash.new
    variables = tokenlines.keys
    variables.each do |var|
      automata = Automata.new
      automata.build(tokenlines[var])
      $machines[var] = automata
      break
    end
  end

  def check_wirth(file)
    tokenize(file)
    puts "Analysing language"
    grammar(1)
  end

  def expression(state)
    current_token = $tokens.shift
    case state
    when 6
      if current_token[0] == "("
        expression(8)
      elsif current_token[0] == "["
        expression(10)
      elsif current_token[0] == "{"
        expression(12)
      elsif is_variable(current_token[0])
        expression(7)
      elsif is_terminal(current_token[0])
        expression(7)
      else
        $tokens.insert(0,current_token)
        expression(7)
      end
    when 7
      if current_token[0] == "("
        expression(8)
      elsif current_token[0] == "["
        expression(10)
      elsif current_token[0] == "{"
        expression(12)
      elsif current_token[0] == "|"
        expression(6)
      elsif is_variable(current_token[0])
        expression(7)
      elsif is_terminal(current_token[0])
        expression(7)
      else
        $tokens.insert(0,current_token)
        return true
      end
    when 8
      $tokens.insert(0,current_token)
      if expression(6)
        expression(9)
      end
    when 9
      if current_token[0] == ")"
        expression(7)
      else
        raise Exception.new("Malformed expression on line #{current_token[1]}, expected ) but found #{current_token[0]} instead")
      end
    when 10
      $tokens.insert(0,current_token)
      if expression(6)
        expression(11)
      end
    when 11
      if current_token[0] == "]"
        expression(7)
      else
        raise Exception.new("Malformed expression on line #{current_token[1]}, expected ] but found #{current_token[0]} instead")
      end
    when 12
      $tokens.insert(0,current_token)
      if expression(6)
        expression(13)
      end
    when 13
      if current_token[0] == "}"
        expression(7)
      else
        raise Exception.new("Malformed expression on line #{current_token[1]}, expected } but found #{current_token[0]} instead")
      end
    end
  end

  def grammar(state)
    if $tokens.size == 0
      if state == 5
        return true
      else
        raise Exception.new("Unexpected end of file")
      end
    end
    current_token = $tokens.shift
    case state
    when 1
      if is_variable(current_token[0])
        grammar(2)
      else
        raise Exception.new("Expected non terminal on line #{current_token[1]}, but found #{current_token[0]} instead")
      end
    when 2
      if current_token[0] == "="
        grammar(3)
      else
        raise Exception.new("Expected = sign on line #{current_token[1]}, but found #{current_token[0]} instead")
      end
    when 3
      $tokens.insert(0,current_token)
      if expression(6)
        grammar(4)
      else
        false
      end
    when 4
      if current_token[0] == "."
        grammar(5)
      else
        raise Exception.new("Expected . char on line #{current_token[1]}, but found #{current_token[0]} instead")
      end
    when 5
      if is_variable(current_token[0])
        grammar(2)
      else
        raise Exception.new("Expected non terminal on line #{current_token[1]}, but found #{current_token[0]} instead")
      end
    end
  end

  def tokenize(file)
    $tokens = []
    file = File.new(file, "r")
    line_number = 1
    while (line = file.gets)
      line.split(" ").each { |token| $tokens << [token,line_number] }
      line_number += 1
    end
  end

  def is_variable(token)
    token[0] =~ /[[:alpha:]]/
  end

  def is_terminal(token)
    token[0] == "\""
  end

  def reduce_wirth(file)
    tokenlines = Hash.new
    file = File.new(file, "r")
    $root = nil
    while (line = file.gets)
      variable = line.split("=",2).first[0..-2]
      $root ||= variable
      line = line.split("=",2).last[1..-3]
      tokenlines[variable] = line.split(" ")
    end

    finalhash = Hash.new
    finalhash[$root] = [substitute(tokenlines,tokenlines[$root]),"."].flatten!
    finalhash


    # loop do
    #   terminals = []
    #   tokenlines.each do |key, value|
    #     terminals << key if not has_variables(value)
    #   end
    #
    #   break if terminals.empty?
    #   current = terminals.pop
    #   tokenlines.each do |key, value|
    #     newvalue = value.map! { |x| x == current ? ["(",tokenlines[current],")"] : x }.flatten!
    #     tokenlines[key] = value
    #   end
    #   tokenlines.delete(current)
    # end

    # finalhash = Hash.new
    # variables = tokenlines.keys
    # variables.each do |var|
    #   newexpression = substitute(tokenlines,var,[])
    #   finalhash[var] = [newexpression,"."].flatten!
    # end
    # # puts finalhash["Commands"].join(" ")
    # finalhash

  end

  def substitute(tokenlines,token)
    expression = token
    current = Array.new
    loop do
      break if not has_variables(expression)
      expression.map do |token|
        if (not is_variable(token)) || token == $root
          current << token
        else
          current << ["(",tokenlines[token],")"]
        end
      end
      current.flatten!
      expression = current
      current = Array.new
    end
    expression
  end

  def has_variables(tokenline)
    tokenline.each do |token|
      return true if is_variable(token) && token != $root
    end
    false
  end

  def syntactic(tokens)
    $tokenController = TokenController.new tokens
    $error = nil
    if run($root,0)
      return true
    else
      puts_red $error
      return false
    end
  end

  def run(machine,state)
    if $tokenController.empty
      if $machines[machine].is_final(state)
        return true
      else
        $error ||= "Unexpected end of file"
        return false
      end
    end
    p "-",machine,"- error" if $machines[machine] == nil
    next_states = $machines[machine].get_next_states([state,$tokenController.get_first_trans])
    if next_states != nil
      $tokenController.consume
      next_states.each do |next_state|
        return true if run(machine,next_state)
      end
    end
    next_machine = $machines[machine].get_submachine_transitions[state]
    if next_machine != nil
      run(next_machine,0)
      next_s = $machines[machine].get_next_states([state,next_machine])
      return run(machine,next_s.first)
    end
    $error ||= "Error on line #{$tokenController.get_first_line}, unexpected #{$tokenController.get_first_trans}"
    return false
    puts "Compiler error. Please send a notification to the developer"
  end

  def puts_red(string)
    puts "\e[31m#{string}\e[0m"
  end

end
