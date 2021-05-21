module Choosable
  VALUES = ['Rock', 'Paper', 'Scissors', 'Lizard', 'Spock']
  VALID_INPUTS = ['Rock', 'r', 'Paper', 'p', 'Scissors', 's', 'Lizard', 'l', \
                  'Spock', 'k']
  VALUES_USER_TEXT = ['(R)ock', '(P)aper', '(S)cissors', '(L)izard', 'Spoc(k)']
  FULL_VALUES = { 'r' => VALUES[0], 'p' => VALUES[1], 's' => VALUES[2],
                  'l' => VALUES[3], 'k' => VALUES[4] }
  DEFEATS = {  VALUES[0] => [VALUES[2], VALUES[3]],
               VALUES[1] => [VALUES[0], VALUES[4]],
               VALUES[2] => [VALUES[1], VALUES[3]],
               VALUES[3] => [VALUES[1], VALUES[4]],
               VALUES[4] => [VALUES[0], VALUES[2]] }

  def self.calculate_choice(personality, choice_num)
    counter = 0
    choice = ""
    personality.each do |move, probability|
      counter += probability
      if counter >= choice_num
        choice = move
        break
      end
    end

    choice
  end

  def self.choose(personality = nil)
    choice_class_name = if personality
                          determine_class_choice(personality)
                        else
                          VALUES.sample
                        end

    choice_class_str = "Choosable::#{choice_class_name}"
    Object.const_get(choice_class_str).new
  end

  def self.convert_abbreviation(abbreviation)
    FULL_VALUES[abbreviation.downcase]
  end

  def self.determine_class_choice(personality)
    choice_num = Random.rand(1..100)

    calculate_choice(personality, choice_num)
  end

  class Choice
    def >(other_move)
      DEFEATS[value].include?(other_move.value)
    end

    def <(other_move)
      other_move > self
    end

    def to_s
      value
    end

    protected

    attr_reader :value
  end

  class Rock < Choice
    def initialize
      @value = "Rock"
    end
  end

  class Paper < Choice
    def initialize
      @value = "Paper"
    end
  end

  class Scissors < Choice
    def initialize
      @value = "Scissors"
    end
  end

  class Lizard < Choice
    def initialize
      @value = "Lizard"
    end
  end

  class Spock < Choice
    def initialize
      @value = "Spock"
    end
  end
end

module InputValidation
  YES_NO = ['y', 'yes', 'n', 'no']

  def self.retrieve(prompt, options, error_msg, case_insensitive = true)
    input = ""

    loop do
      puts prompt

      input = gets.chomp

      input.downcase! if case_insensitive
      valid_inputs = case_insensitive ? options.map(&:downcase) : options

      break if valid_inputs.include?(input)
      puts error_msg
    end

    input
  end
end

class Player
  include Choosable
  attr_accessor :move, :name

  def initialize
    set_name
  end
end

class Human < Player
  def choose
    choice_prompt = "Choose one of the following: " \
                    "#{Choosable::VALUES_USER_TEXT.join(', ')}"

    choice = InputValidation.retrieve(choice_prompt, Choosable::VALID_INPUTS,\
                                      "That's an invalid choice.").capitalize

    if choice.length == 1
      choice = Choosable.convert_abbreviation(choice)
    end

    self.move = Object.const_get("Choosable::#{choice}").new
  end

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
end

class Computer < Player
  PERSONALITIES = { "R2D2" => { "Rock" => 34, "Paper" => 33, "Scissors" => 33 },
                    "Hal" => { "Scissors" => 50, "Lizard" => 50 },
                    "C3PO" => { "Spock" => 50, "Paper" => 30, "Rock" => 20 },
                    "Wall-E" => { "Lizard" => 100 },
                    "NCC-1701 Computer" => { "Spock" => 100 } }

  def choose
    self.move = Choosable.choose(personality)
  end

  def set_name
    names = ['R2D2', 'Hal', 'C3P0', 'Wall-E', 'NCC-1701 Computer',\
             'Rando Botrissian']
    self.name = names.sample
    @personality = PERSONALITIES[name]
  end

  attr_reader :personality
end

class Scoreboard
  SCOREBOARD_WIDTH = 40
  def initialize(players, target_score)
    @scores = Hash.new
    players.each { |player| scores[player] = 0 }
    @target_score = target_score
  end

  def add_point(player)
    scores[player] += 1
  end

  def display
    line_separator = "-" * SCOREBOARD_WIDTH
    puts line_separator
    puts
    scores.each { |player, score| print "#{player.name}: #{score}          " }
    puts
    puts line_separator
  end

  def info
    info_string = ""
    scores.each do |player, score|
      info_string << "#{player.name}: #{score}\t"
    end
    info_string
  end

  def winner?
    scores.any? { |_, score| score == target_score }
  end

  def winner
    scores.key(target_score)
  end

  def zeros!
    scores.transform_values! { |_| 0 }
  end

  private

  attr_accessor :scores
  attr_reader :target_score
end

class History
  SEPARATING_LINE_WIDTH = 45

  def initialize(history_header = nil)
    @has_header = !history_header.nil?
    @history = (has_header ? [[history_header]] : [])
    @list_num = 0
  end

  def add_banner(banner)
    banner_text = banner.center(SEPARATING_LINE_WIDTH)
    new_list(banner_text, false)
  end

  def add_items(*items)
    items.flatten.each do |item|
      current_list << "#{list_num}-#{current_list_row_num}. #{item}"
      self.current_list_row_num += 1
    end
  end

  def display
    puts "\nHere's your game history:\n"
    to_s
  end

  def new_list(list_header, increase_list_num = true)
    history << current_list unless current_list.nil? ||
                                   current_list.length < 2

    self.current_list_row_num = 1
    self.list_num += 1 if increase_list_num

    self.current_list = ["-" * SEPARATING_LINE_WIDTH]

    current_list << list_header unless list_header.nil?
  end

  def to_s
    output_list(history)
    output_list(current_list) unless current_list.length < 2
    puts "-" * SEPARATING_LINE_WIDTH + "\n\n"
  end

  private

  attr_accessor :current_list, :history, :list_num, :current_list_row_num
  attr_reader :has_header

  def output_list(list)
    list.each do |sub_list|
      if sub_list.class == Array
        sub_list.each { |item| puts item }
      else
        puts sub_list
      end
    end
  end
end

class RPSGame
  TIE = :tie
  POINTS_NEEDED_WIN_MATCH = 5

  def initialize
    clear_screen
    @human = Human.new
    @computer = Computer.new
    @match_scores = Scoreboard.new([human, computer], POINTS_NEEDED_WIN_MATCH)
    @program_history = History.new("Rock, Paper, Scissors initiated!")
  end

  def play
    init_program

    loop do
      # Start of a new match
      program_history.add_banner("~~~Start of a new match~~~")

      play_match_games

      display_match_winner_text

      break if already_quit || quit?
      reset_match
    end
    end_program
  end

  private

  attr_accessor :human, :computer, :match_scores, :quit, :already_quit, \
                :game_winner
  attr_reader :program_history

  def clear_screen
    system 'clear'
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

  def display_game_winner
    if game_winner == TIE
      puts "It's a tie!"
    else
      puts "#{game_winner.name} won!"
    end
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, Lizard, Spock. Goodbye!"
  end

  def display_match_winner_text
    return unless match_scores.winner?
    puts "\n\nEND OF THE MATCH! #{match_scores.winner.name} wins!\n"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Lizard, Spock!"
  end

  def end_program
    program_history.display
    display_goodbye_message
  end

  def game_end?
    match_scores.winner? || quit?
  end

  def game_history
    this_game = []
    this_game << "#{human.name} chose #{human.move}..."
    this_game << "#{computer.name} chose #{computer.move}..."
    this_game << if game_winner == TIE
                   "This game was a tie."
                 else
                   "#{game_winner.name} won this game."
                 end
    this_game << "Scores: #{match_scores.info}"

    this_game
  end

  def init_program
    clear_screen
    display_welcome_message
  end

  def make_moves
    human.choose
    computer.choose
  end

  def play_another_game?
    prompt_str = "Would you like to continue this match with another game? " \
                 "(y/n)"
    another_game = InputValidation.retrieve(prompt_str, \
                                            InputValidation::YES_NO, \
                                            "You must enter y or n")

    another_game == "y"
  end

  def play_another_match?
    prompt_str = "Would you like to play another match to see who " \
                           "gets to #{POINTS_NEEDED_WIN_MATCH} wins first?"

    another_match = InputValidation.retrieve(prompt_str, \
                                             InputValidation::YES_NO, \
                                             "You must enter y or n")

    another_match == "y"
  end

  def play_match_games
    loop do
      run_game

      break if game_end?
      clear_screen
    end

    return unless match_scores.winner?
    program_history.add_banner("#{match_scores.winner.name} wins the match!")
  end

  def quit?
    if match_scores.winner? && play_another_match?
      self.quit = false
    elsif !match_scores.winner? && play_another_game?
      self.quit = false
    else
      self.quit = true
      self.already_quit = true
    end
  end

  def reset_match
    match_scores.zeros!
    clear_screen
  end

  def run_game
    program_history.new_list("New game started")
    match_scores.display

    make_moves
    display_moves

    determine_game_winner
    display_game_winner

    match_scores.add_point(game_winner) unless game_winner == TIE
    program_history.add_items(game_history)
  end
end

RPSGame.new.play
