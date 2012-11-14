class Hovercat
  ALPHABET = "abcdefghijklmnoprqstuvwxyz@_,-"

  def alphabet
    ALPHABET
  end

  def initialize
    @square = `lsquare/square #{alphabet}`.split("\n").map {|x| x.split(" ")}
    puts @square.map {|x| x.join " "}.join("\n")
  end

  def encrypt(string)
    mode = :right
    x,y = 0,0
    result = ""
    i = 0
    char = string[i]
    while i < string.length
      x,y = move(x, y, mode)

      if get(x,y) == char
        old_char = char
        i += 1
        char = string[i]
        char = "@" if char == old_char

        if i == string.length
          new_mode = nil
        else
          new_mode = new_direction(x, y, char, mode)
        end

        result += emit_tokens(x, y, mode, new_mode)

        mode = new_mode
      end
    end

    return result
  end

  def emit_tokens(x, y, mode, new_mode)
    result = ""
    result += get(x, y-1) if new_mode == :up or [:up, :down].include? mode
    result += get(x+1, y) if new_mode == :right or [:left, :right].include? mode
    result += get(x, y+1) if new_mode == :down or [:up, :down].include? mode
    result += get(x-1, y) if new_mode == :left or [:left, :right].include? mode
    return result
  end

  def move(x, y, mode)
    if mode == :right
      x += 1
    elsif mode == :down
      y += 1
    elsif mode == :left
      x -= 1
    elsif mode == :up
      y -= 1
    end

    return [x,y]
  end

  def decrypt(string)
    char = nil
    mode = :right
    done = false
    i = 0
    x,y = [0,0]
    result = ""
    while not done
      triple = string[i...i+3]
      done = triple.length == 2
      x,y = triple_center(x,y,mode,triple)
      this_char = get(x,y)
      this_char = char if this_char == "@"
      char = this_char
      result += this_char
      mode = decryption_new_direction(x,y,mode,triple)
      i += 3
    end
    return result
  end

  def decryption_new_direction(x,y,mode, triple)
    if is_horizontal(mode)
      return :up if triple[0] == get(x,y-1)
      return :down if triple[1] == get(x,y+1)
    elsif is_vertical(mode)
      return :right if triple[1] == get(x+1, y)
      return :left if triple[2] == get(x-1, y)
    end
  end

  def double_center(x,y,mode,triple)
    if mode == :left or mode == :right
      alphabet.length.times do |x|
        return [x,y] if get(x+1,y) == triple[0] and get(x-1,y) == triple[1]
      end
    else
      alphabet.length.times do |y|
        return [x,y] if get(x,y-1) == triple[0] and get(x,y+1) == triple[1]
      end
    end
  end

  def triple_center(x,y,mode,triple)
    return double_center(x,y,mode,triple) if triple.length == 2
    if is_horizontal(mode)
      alphabet.length.times do |x|
        # case looks like this
        #
        #
        #     triple[2] center triple[0]
        #              triple[1]
        #
        #
        # or case looks like this
        #
        #                    triple [0]
        #           triple[2] center  triple[1]
        #
        formation1 = get_triple([[x+1,y], [x,y+1], [x-1,y]])
        formation2 = get_triple([[x,y-1], [x+1,y],[ x-1,y]])
        return [x,y] if [formation1, formation2].include? triple
      end
    elsif is_vertical(mode)
      alphabet.length.times do |y|
        #case looks like this
        #         triple[0]
        #         center triple[1]
        #         triple[2]
        # or case looks like this
        #            triple[0]
        #triple [2]   center
        #            triple[1]
        formation1 = get_triple([[x,y-1], [x+1, y], [x, y+1]])
        formation2 = get_triple([[x,y-1], [x,y+1], [x-1,y]])
        return [x,y] if [formation1, formation2].include? triple
      end
    end
  end

  def get_triple(coords)
    coords.map {|pos| get(pos[0], pos[1])}.join("")
  end


  def new_direction(x, y, char, current_direction)
    if is_horizontal(current_direction)
      position = search_column(x, char)
      return :up if position == x
      if position > y
        return :down
      else
        return :up
      end
    elsif is_vertical(current_direction)
      position = search_row(y, char)
      return :right if position == y
      if position < x
        return :left
      else
        return :right
      end
    end
  end

  def is_vertical(mode)
    (mode == :up) or (mode == :down)
  end

  def is_horizontal(mode)
    (mode == :left) or (mode == :right)
  end

  def search_row(y, value)
    alphabet.length.times do |x|
      return x if get(x,y) == value
    end
  end

  def search_column(x, value)
    alphabet.length.times do |y|
      return y if get(x,y) == value
    end

    return nil
  end

  def get(x,y)
    x %= alphabet.length
    y %= alphabet.length
    return @square[y][x]
  end
end


c = Hovercat.new
["words", "cows", "you", "just", "write", "what", "im", "typing", "right", "now", "boooom", "________"].each do |word|
  r = c.encrypt(word)
  if c.decrypt(r) != word
    puts "fail #{word}"
  else
    print "."
  end
end
puts
