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
      if mode == :right
        x += 1
      elsif mode == :down
        y += 1
      elsif mode == :left
        x -= 1
      elsif mode == :up
        y -= 1
      end

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
        if mode == :left or mode == :right
          result += get(x, y-1) if new_mode == :up
          result += get(x+1, y)
          result += get(x, y+1) if new_mode == :down
          result += get(x-1, y)
        elsif mode == :down or mode == :up
          result += get(x, y-1)
          result += get(x+1, y) if new_mode == :right
          result += get(x, y+1)
          result += get(x-1, y) if new_mode == :left
        end

        mode = new_mode
      end
    end
    return result
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
    if mode == :right or mode == :left
      return :up if triple[0] == get(x,y-1)
      return :down if triple[1] == get(x,y+1)
    elsif mode == :up or mode == :down
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
    if mode == :right or mode == :left
      alphabet.length.times do |x|
        # case looks like this
        #
        #
        #     triple[2] center triple[0]
        #              triple[1]
        #
        #
        if triple[0] == get(x,y) and triple[1] == get(x-1, y+1) and (triple.length == 2 or triple[2] == get(x-2,y))
          return [x-1,y]
        # case looks like this
        #
        #                    triple [0]
        #           triple[2] center  triple[1]
        #
        elsif triple[0] == get(x, y-1) and triple[1] == get(x+1, y) and (triple.length == 2 or triple[2] == get(x-1, y))
          return [x,y]
        end
      end
    elsif mode == :down or mode == :up
      alphabet.length.times do |y|
        #case looks like this
        #         triple[0]
        #         center triple[1]
        #         triple[2]
        if triple[0] == get(x,y) and triple[1] == get(x+1, y+1) and (triple.length == 2 or triple[2] == get(x,y+2))
          return [x, y+1]
        #case looks like this
        #            triple[0]
        #triple [2]   center
        #            triple[1]
        elsif triple[0] == get(x, y-1) and triple[1] == get(x, y+1) and (triple.length == 2 or triple[2] == get(x-1, y))
          return [x,y]
        end
      end
    end
  end


  def new_direction(x, y, char, current_direction)
    if current_direction == :left or current_direction == :right
      position = search_column(x, char)
      return :up if position == x
      if position > y
        return :down
      else
        return :up
      end
    elsif current_direction == :down or current_direction == :up
      position = search_row(y, char)
      return :right if position == y
      if position < x
        return :left
      else
        return :right
      end
    end
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
