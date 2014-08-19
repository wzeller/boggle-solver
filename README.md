boggle-solver
=============

I used the problem of finding all possible legal words in Boggle to investigate the "trie" data structure in Ruby.

Currently, if you clone this repo into a folder and run boggle_solver.rb, the code will load an English dictionary into a trie, create and "solve" 1000 Boggle boards, and output the number of words found, the longest word, and the running time for the Boggle-solving part (the dictionary takes around 7 seconds to load).

The general description of how I solved this problem is as follows:

(1) add the entire Dictionary into a retrieval tree, allowing O(k) lookups for prefixes and words;
(2) for any given Boggle board, make 16 small retrieval trees (starting at each letter), and only
continue down any particular branch (via depth-first search) if it is a prefix for another word; 
(3) when you hit a word, add it to an array for the entire board and return the results sorted by word length.

The program runs very quickly, solving a boggle board in around .1 seconds.  

Possible TODOs include making a GUI, making it easier to enter a new board (by default the code generates a random board), and possibly implementing a computer boggle player.  

I also want to use the trie structure to make an "auto-complete" algorithm, possibly with results sorted by the frequency of that particular word.  A trie may also allow for a personalized auto-complete (or other interesting data) based on a sample of a single user's text.  
