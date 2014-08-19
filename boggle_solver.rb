require 'benchmark'
require_relative 'node'
require_relative 'trie'
dictionary_filename = File.dirname(__FILE__) + "/dictionaryTree.txt"
DICTIONARY_TRIE = Marshal.load(File.read(dictionary_filename))

class Boggle

  attr_accessor :board

  def initialize(dictionary=DICTIONARY_TRIE)
    @board = new_board
    @dictionary = dictionary 
  end

  # makes a random board if none is inputted
  def new_board 
    board = Array.new(4){Array.new(4)}
    (0..3).each do |i|
      (0..3).each do |j|
        board[i][j] = ('a'..'z').to_a.sample
      end
    end
    board
  end

  def display
    @board.each{|row| puts row.join(",") + " "}
  end
  
  # Returns a sorted list of all unique possible boggle words for the board.
  # Essentially, it builds 16 different tries -- one at each of the 16 letters --
  # and performs a depth-first search from that starting letter to find all possible
  # words from each, combines them into an array and returns the list.

  def get_possible_words
    total_words = []
    (0..3).each do |i|
      (0..3).each do |j|
        total_words += make_boggle_trie(i, j)
      end
    end
    total_words.uniq.sort_by{|word| word.length}
  end

  private 
  
  # Simply returns the coordinates for all adjacent squares of any 
  # square on the boggle board. It also returns the character associated
  # with each square, which is used in #make_boggle_trie to make 
  # new nodes.  

  def get_adj_sqrs(i, j)
    sqrs = []
    xadj = [-1, -1, -1, 0, 0, 1, 1, 1]
    yadj = [-1, 0, 1, -1, 1, -1, 0, 1]
    idx = 0
    8.times do 
      x = i+xadj[idx]
      y = j+yadj[idx]
      sqrs << [x, y, @board[x][y]] unless (x < 0 || x > 3 || y < 0 || y > 3) 
      idx += 1 
    end
    sqrs 
  end

  # We use this method to make a new trie starting at each of the 16 letters on 
  # the board.  Because the rules of Boggle prevent doubling back and visiting
  # a node twice, we also need to store the nodes visited (i.e., "ancestors").
  # To be able to tell whether the adjacent squares are "ancestors," we store
  # the coordinates for every node and check if they are the same as the adjacent
  # square.

  # The method (and its helper functions) has a few steps:
  # 1. make a new trie with the head_node at the position x,y
  # 2. put the head_node into a stack
  # 3. while the stack is not empty:
  #   3a. pop off the last node in the stack, which is called "new_parent"
  #   3b. get all of its adjacent squares
  #   3c. check whether any of them have the same x,y coords as
  #       the node's ancestors; if so, delete those squares
  #   3d. make child nodes out of the remainind adjacent squares
  #       with the "new_parent" as well as all of "new_parent"'s
  #       ancestors as the child's ancestors.   
  #   3e. take all the child's ancestors, grab the letters associated with 
  #       each, join and reverse them into a string, and then:
  #       3e1.  check if it's either a prefix or a word in the dictionary
  #             3e1A. if so, add to stack.  
  #             3e1B. if also a word of the right length, add to array of words
  #             3e1C. if not a prefix or word, do not add to stack (it's a dead end)
  # 4.  when the stack is empty, every path with a word has been traversed and 
  #     we return the array of words.


  # helper to remove all visited nodes and prevent backtracking
  def delete_visited_nodes(new_parent, potl_neighbors)
    new_parent.ancestors.each do |ancestor|
      potl_neighbors.each do |child|
        if ancestor.x == child[0] && ancestor.y == child[1]
          potl_neighbors.delete(child) 
        end
      end
    end
  end
  
  # helper to add words and add to stack
  def add_words(prefix, stack, child_node, new_parent, words)
    look_up = @dictionary.is_prefix_or_word?(prefix)
    if look_up
      if prefix.length > 2 && look_up == prefix 
        words << prefix
      end
      new_parent.children[child_node.char] = child_node
      stack << child_node
    end
  end

  # another helper method to make new nodes
  def make_new_nodes(new_parent, potl_neighbors, words, stack)
    potl_neighbors.each do |child|
      child_node = Node.new
      child_node.char = child[2]
      child_node.x = child[0]
      child_node.y = child[1]
      child_node.ancestors << new_parent 
      child_node.ancestors += new_parent.ancestors

      prefix = ""
      child_node.ancestors.each{|node| prefix += node.char}
      prefix = prefix.reverse
      prefix += child_node.char 

      add_words(prefix, stack, child_node, new_parent, words)
    end
  end

  def make_boggle_trie(startx, starty)
    start_node = Node.new
    boggle_trie = Trie.new(start_node)
    start_node.char = @board[startx][starty]
    start_node.x = startx
    start_node.y = starty
    stack = [start_node]
    words = []

    while !stack.empty?  
      new_parent = stack.pop
      potl_neighbors = get_adj_sqrs(new_parent.x, new_parent.y)
      delete_visited_nodes(new_parent, potl_neighbors) 
      make_new_nodes(new_parent, potl_neighbors, words, stack) 
    end
    words
  end
end

all_words = []
time = Benchmark.measure{
  1000.times do 
    game = Boggle.new
    all_words += game.get_possible_words
  end
}

puts all_words.count
puts all_words.sort_by{|word| word.length}.last
puts time 

# 11.670000   0.100000  11.770000 ( 11.767499)
# [Finished in 18.8s]

# The dictionary trie takes about 7 seconds to load, but once loaded the solver can generate all 
# possible boggle words for 1000 randomly-generated Boggle boards in about 11 seconds.  As one 
# boggle board takes around .01 seconds, this appears to be linear time complexity.   


