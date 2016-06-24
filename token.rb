class TokenController

  def initialize( tokens )
    @tokens = tokens
  end

  def empty
    return @tokens.size <= 0
  end

  def consume
    @tokens.shift
  end

  def get_first_trans
    @tokens.first[0]
  end

  def get_first_line
    @tokens.first[1]
  end

end
