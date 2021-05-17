require 'pry'
require 'pry-byebug'

class Player
  attr_accessor :move, :name

  def initialize
    set_name
  end
end

class Human < Player
  def set_name
    n = ""
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter your name."
    end

    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, or scissors:"
      choice = gets.chomp
      break if Move::VALUES.include?(choice)
      puts "Sorry, invalid choice."
    end

    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'X-94)B'].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

class Move
  VALUES = ['rock', 'paper', 'scissors']

  def initialize(value)
    @value = value
  end

  def scissors?
    @value == 'scissors'
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def >(other_move)
    (rock? && other_move.scissors?) ||
      (paper? && other_move.rock?) ||
      (scissors? && other_move.paper?)
  end

  def <(other_move)
    (rock? && other_move.paper?) ||
      (paper? && other_move.scissors?) ||
      (scissors? && other_move.rock?)
  end

  def to_s
    @value
  end
end

class Rule
  def initialize
    # not sure what the "state" of a rule object should be
  end
end

# not sure where "compare" goes yet
def compare(move1, move2); end

class Scoreboard
  def initialize(players, target_score)
    @scores = Hash.new
    players.each { |player| scores[player] = 0 }
    @target_score = target_score
  end

  def add_point(player)
    self.scores[player] += 1
  end

  def winner?
    self.scores.any? { |_, score| score >= target_score }
  end

  def winner
    self.scores.key(target_score)
  end

  def display
    puts ("-" * 40)
    puts
    self.scores.each { |player, score| print "#{player.name}: #{score}\t\t"}
    puts
    puts ("-" * 40)
  end

  private
  attr_accessor :scores
  attr_reader :target_score
end

class RPSGame
  TIE = :tie
  POINTS_NEEDED_WIN_MATCH = 3
  attr_accessor :human, :computer

  def initialize
    clear_screen
    @human = Human.new
    @computer = Computer.new
    @match_scoreboard = Scoreboard.new([human, computer], POINTS_NEEDED_WIN_MATCH)
  end

  def clear_screen
    system 'clear'
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors!"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors. Goodbye!"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def display_game_winner
    if game_winner == TIE
      puts "It's a tie!"
    else
      puts "#{game_winner.name} won!"
    end
  end

  def determine_game_winner
    self.game_winner = if human.move > computer.move
                    human
                  elsif human.move < computer.move
                    computer
                  else
                    TIE
                  end
  end

  def play_another_game?
    answer = nil
    loop do
      puts "Would you like to continue the match? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include?(answer.downcase)
      puts "Sorry, must enter y or n"
    end

    answer == "y"
  end

  def play_another_match?
    answer = nil
    loop do
      puts "Would you like to play another match to see who gets to #{POINTS_NEEDED_WIN_MATCH} wins first?"
      answer = gets.chomp
      break if ['y', 'n'].include?(answer.downcase)
      puts "Sorry, must enter y or n"
    end

    answer == "y"
  end

  def play
    clear_screen
    display_welcome_message

    loop do
      # Start of a new match
      loop do
        # Start of a new game
        match_scoreboard.display
        human.choose
        computer.choose
        display_moves
        determine_game_winner
        display_game_winner
        match_scoreboard.add_point(game_winner) unless game_winner == TIE
        break if match_scoreboard.winner? || quit?
        clear_screen
      end
      # End of a game, same match

      if match_scoreboard.winner?
        puts "\n\nEND OF THE MATCH! #{match_scoreboard.winner.name} wins!\n"
      end

      break if already_quit || quit?
      reset_scores
      clear_screen
    end

    display_goodbye_message
  end

  private
  attr_accessor :match_scoreboard, :quit, :already_quit, :game_winner

  def quit?
    if match_scoreboard.winner? && play_another_match?
      self.quit = false
    elsif !match_scoreboard.winner? && play_another_game?
      self.quit = false
    else
      self.quit = true
      self.already_quit = true
    end
  end

  def reset_scores
    match_scoreboard = Scoreboard.new([human, computer], POINTS_NEEDED_WIN_MATCH)
  end
end

RPSGame.new.play
