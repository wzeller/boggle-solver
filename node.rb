class Node

  attr_accessor :children, :word, :char, :ancestors, :x, :y 

  def initialize(children = {}, char = "", word = false, xpos = 0, ypos = 0)
    @children = children 
    @char = char
    @word = word
    @ancestors = [] # ancestors, x, and y, are only needed when you need to avoid repeat visits
    @x = xpos       # e.g., when putting an English dictionary into a trie, you do not 
    @y = ypos       # need to worry about letters being repeated; on the other hand, 
  end               # when putting a boggle board into a trie, you need to be able to tell
                    # what squares have been traversed (ancestors) to avoid repeat visits

  def add_child(child_node)
    self.children[child_node.char] = child_node
  end

end