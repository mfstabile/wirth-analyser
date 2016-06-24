class Automata

  def build(grammar)
    $symbols = []
    $submachines = Hash.new
    grammar.each do |symb|
      $symbols << symb if (is_variable(symb) or is_terminal(symb)) and not $symbols.include?(symb)
    end
    $stack = [[0,1]]
    $transitionMatrix = Hash.new
    buildTransitions(grammar, 2, 0)
    removeEmptyTransitions
    $transitionMatrix
  end

  def get_next_states(key)
    $transitionMatrix[key]
  end

  def get_submachine_transitions
    $submachines
  end

  def is_variable(token)
    token[0] =~ /[[:alpha:]]/
  end

  def is_terminal(token)
    token[0] == "\""
  end

  def is_final(state)
    return true if state == 1
    return false if not $transitionMatrix[[state,""]]
    $transitionMatrix[[state,""]].each do |nextState|
      return true if is_final(nextState)
    end
    false
  end

  def matrix
    puts $transitionMatrix
  end

  def addTransition(origin,symbol,destination)
    if $transitionMatrix[[origin,symbol]].nil?
      $transitionMatrix[[origin,symbol]] = [destination]
    elsif not $transitionMatrix[[origin,symbol]].include?(destination)
      $transitionMatrix[[origin,symbol]] << destination
    end
  end

  def buildTransitions(tokens, j, lastUsed)
    first, *rest = *tokens
    return if first.nil?
    case first
    when "|"
      addTransition(lastUsed,"",$stack.last.last)
      lastUsed = $stack.last.first
    when "("
      $stack.push([lastUsed,j])
      j = j+1
    when "["
      addTransition(lastUsed,"",j)
      $stack.push([lastUsed,j])
      j = j + 1
    when "{"
      addTransition(lastUsed,"",j)
      $stack.push([j,j])
      lastUsed = j
      j = j + 1
    when "}", "]", ")"
      addTransition(lastUsed,"",$stack.last.last)
      lastUsed = $stack.last.last
      $stack.pop
    when "."
      addTransition(lastUsed,"",$stack.last.last)
      $stack.pop
    else
      addTransition(lastUsed,first,j)
      lastUsed = j
      j = j+1
    end
    $j = j
    buildTransitions(rest, j, lastUsed)
  end

  def copyTransitions(origin, dest)
    $symbols.each do |symbol|
      if $transitionMatrix[[dest,symbol]]
        $transitionMatrix[[dest,symbol]].each { |st| addTransition(origin,symbol,st) }
      end
    end
    if $transitionMatrix[[dest,""]]
      $transitionMatrix[[dest,""]].each do |destination|
        copyTransitions(origin, destination)
      end
    end
  end

  def removeEmptyTransitions
    for origin in 0..$j+1
      if $transitionMatrix[[origin,""]]
        $transitionMatrix[[origin,""]].each { |dest| copyTransitions(origin,dest) }
      end
    end
    keys = $transitionMatrix.keys
    keys.each do |key|
      if is_variable(key[1])
        $submachines[key[0]] = key[1]
      end
    end
  end
end
