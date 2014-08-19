# A retrieval tree, or "trie", is a type of trie characterized by nodes having data 
# of one character.  Connections between the nodes can represent connections of 
# letters, or words.  Although taking up a lot of space (a list of English words 
# is around 50MB), the lookup and insertion times are extremely fast -- on the order
# of n operations, where n is the length of the string.  There are also no collisions
# possible and no hash function needed, which makes a trie superior in some cases to a hash.  
# Finally, at any given node, you can find out all the words that are prefixed by the 
# letters so far, which is ideal for appilcations like autocomplete.  

# Read more here: http://en.wikipedia.org/wiki/Trie

class Trie

  attr_reader :head_node

  def initialize(head_node)
    @head_node = head_node
  end
  
  def add_word(string)
    length = string.length
    idx = 0
    head_node = @head_node # at each letter we replace head_node 
                           # with the child corresponding to the next letter
    string.each_char do |char|
      if !head_node.children[char].nil?      # will be true if there is already a node with the letter
        head_node = head_node.children[char] 
      else
        new_child = Node.new({}, char)       # if no node with letter, make one
        head_node.add_child(new_child)
        head_node = head_node.children[char] 
      end
      idx += 1
      head_node.word = true if idx == string.length-1 # mark the last letter as a word
    end
  end

  #returns false if neither, true if only prefix, and the string if a word
  def is_prefix_or_word?(string)
    head_node = @head_node
    length = string.length
    idx = 0
    string.each_char do |char|
      if !head_node.children[char].nil? #fastest lookup -- true if letter is among the children
        head_node = head_node.children[char] 
      else
        return false
      end 
      idx += 1
      if idx == string.length && head_node.word
        return string
      end
    end
    true
  end

end