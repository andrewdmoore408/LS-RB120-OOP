module Format
  def self.joinor(items, separator: ',', word: "or")
    if items.length <= 2
      joinor_small(items, word)
    else
      joinor_large(items, separator, word)
    end
  end

  def self.joinor_large(items, separator, word)
    text = items.map { |item| "#{item}#{separator}" }
    text.pop
    text.push(word, items.last)
    text.join(' ')
  end

  def self.joinor_small(items, word)
    return items.first if items.length == 1

    "#{items.first} #{word} #{items.last}"
  end
end

module InputValidation
  YES_NO = ['y', 'yes', 'n', 'no']

  def self.retrieve(prompt, options, error_msg, case_insensitive = true)
    input = ""

    loop do
      puts prompt

      input = gets.chomp.strip

      input.downcase! if case_insensitive
      valid_inputs = case_insensitive ? options.map(&:downcase) : options

      break if valid_inputs.include?(input)
      puts error_msg
    end

    input
  end
end

class Scoreboard
  SCOREBOARD_WIDTH = 40
  def initialize(players, target_score)
    @@scores = Hash.new
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

  attr_reader :target_score

  def scores
    @@scores
  end
end

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # columns
                  [[1, 5, 9], [3, 5, 7]]              # diagonals
  CENTER_SQUARE = 5

  def initialize
    @squares = {}
    (1..9).each do |key|
      @squares[key] = Square.new
    end
  end

  def center_open?
    unmarked_keys.include?(Board::CENTER_SQUARE)
  end

  def square_at_risk(marker)
    WINNING_LINES.each do |line|
      line_markers = squares.values_at(*line).map(&:marker)

      if line_markers.count(Square::INITIAL_MARKER) == 1 && \
         line_markers.count(marker) == 2
        line.each { |square| return square if squares[square].unmarked? }
      end
    end

    nil
  end

  def square_at_risk?(marker)
    !!square_at_risk(marker)
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def draw
    puts "     |     |"
    puts "  #{squares[1]}  |  #{squares[2]}  |  #{squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{squares[4]}  |  #{squares[5]}  |  #{squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{squares[7]}  |  #{squares[8]}  |  #{squares[9]}"

    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def winning_marker
    # returns winning marker or nil
    WINNING_LINES.each do |line|
      return squares[line[0]].marker if winning_marker_found?\
        (squares.values_at(*line))
    end
    nil
  end

  def full?
    unmarked_keys.empty?
  end

  def reset
    (1..9).each do |key|
      squares[key] = Square.new
    end
  end

  def someone_won?
    !!winning_marker
  end

  def unmarked_keys
    squares.keys.select { |key| squares[key].unmarked? }
  end

  def []=(key, marker)
    squares[key].marker = marker
  end

  private

  attr_accessor :squares

  def winning_marker_found?(squares)
    markers = squares.map(&:marker)

    (markers.uniq.length == 1) && (markers.count(Square::INITIAL_MARKER).zero?)
  end
end

class Square
  INITIAL_MARKER = ' '
  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

class Player
  attr_reader :marker, :name

  def initialize
    @name = set_name
    @marker = set_marker
  end
end

class Human < Player
  def set_marker
    marker = nil

    loop do
      puts "Choose one character to be your marker on the board: "
      marker = gets.chomp.strip
      break unless marker.empty? || marker.length > 1
      puts "Invalid--please enter exactly one character."
    end

    marker
  end

  def set_name
    name = nil

    loop do
      puts "Enter your name: "
      name = gets.chomp.strip
      break unless name.empty?
      puts "You can't have an empty name!"
    end

    name
  end
end

class Computer < Player
  NAMES = ['Ticky-Tac 3000', 'Hal', 'Robo-Toe', 'Type-O (Positive)', 'Wall-E']
  DEFAULT_MARKER = 'O'
  ALTERNATE_MARKER = 'E'

  def initialize(default_marker: true)
    @name = set_name
    @marker = if default_marker
                DEFAULT_MARKER
              else
                ALTERNATE_MARKER
              end
  end

  def set_name
    NAMES.sample
  end
end

class TTTGame
  include Format, InputValidation

  POINTS_NEEDED_WIN_MATCH = 5

  def initialize
    clear
    display_welcome_message
    @board = Board.new
    @human = Human.new
    @computer = Computer.new(determine_computer_marker)
    @match_scores = Scoreboard.new([human, computer], POINTS_NEEDED_WIN_MATCH)
    @current_player = determine_starting_player(human.name)
    @already_quit = false
  end

  def play
    clear
    play_match
    display_goodbye_message
  end

  private

  attr_accessor :current_player, :already_quit, :match_scores
  attr_reader :board, :human, :computer

  def alternate_current_player
    self.current_player = if human_turn?
                            computer
                          else
                            human
                          end
  end

  def can_win?(marker)
    board.square_at_risk?(marker)
  end

  def clear
    system 'clear'
  end

  def clear_screen_and_display_scores_and_board
    clear
    display_scores_and_board
  end

  def computer_moves
    square = find_computer_square
    board[square] = computer.marker
  end

  def current_player_moves
    if human_turn?
      human_moves
    else
      computer_moves
    end
  end

  def determine_computer_marker
    default = !(human.marker == "O")

    { default_marker: default }
  end

  def determine_starting_player(human_name)
    prompt = "Who would you like to go first? " \
             "(\"#{human_name}\", \"Computer\", or \"Random\"?)"
    err_msg = "You must select one of these three options"
    turn = InputValidation.retrieve(prompt, [human_name, "Computer", "Random"],\
                                    err_msg)
    case turn.downcase
    when human_name.downcase then human
    when "computer" then computer
    else [human, computer].sample
    end
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
    puts
  end

  def display_scores_and_board
    puts "First player to #{POINTS_NEEDED_WIN_MATCH} wins takes the match."
    match_scores.display
    puts "You're a #{human.marker}. Computer is a #{computer.marker}."
    puts
    board.draw
    puts
  end

  def display_play_another_game_message
    puts "Let's keep playing!"
    puts
  end

  def display_game_result
    clear_screen_and_display_scores_and_board

    case board.winning_marker
    when human.marker
      puts "You won!"
    when computer.marker
      puts "Computer won!"
    else
      puts "It's a tie!"
    end
  end

  def display_match_result
    puts
    puts "With a final score of: #{match_scores.info}"
    puts
    puts "#{match_scores.winner.name} won the match!"
  end

  def end_match?
    puts "Current scores are #{match_scores.info}"
    puts "First player to #{POINTS_NEEDED_WIN_MATCH} wins."
    prompt = "Would you like to continue this round? (y/n)"
    err_msg = "You must enter y or n"
    answer = InputValidation.retrieve(prompt, YES_NO, err_msg)

    answer == 'n'
  end

  # rubocop:disable Metrics/AbcSize
  def find_computer_square
    if can_win?(computer.marker)
      board.square_at_risk(computer.marker)
    elsif can_win?(human.marker)
      board.square_at_risk(human.marker)
    elsif board.center_open?
      Board::CENTER_SQUARE
    else
      board.unmarked_keys.sample
    end
  end
  # rubocop:enable Metrics/AbcSize

  def human_moves
    loop do
      puts "Choose a square (#{Format.joinor(board.unmarked_keys)})"
      square = gets.chomp.strip

      if valid_move_input?(square)
        board[square.to_i] = human.marker
        break
      end

      puts "Sorry, that's not a valid choice."
    end
  end

  def human_turn?
    current_player == human
  end

  def integer?(str_input)
    str_input.to_i.to_s == str_input
  end

  def main_game
    loop do
      display_scores_and_board
      players_make_moves

      display_game_result
      match_scores.add_point(which_player(board.winning_marker)) \
        if board.someone_won?

      break if match_won? || quit_match?

      reset_game
      display_play_another_game_message
    end
  end

  def match_won?
    match_scores.winner?
  end

  def play_match
    # need loop to check for win
    # ask player if they want to play another match
    # prompt to quit or continue at the end of a game
    loop do
      main_game
      break if already_quit
      display_match_result if match_won?
      break if quit_program?
      reset_match
    end
  end

  def players_make_moves
    loop do
      current_player_moves
      break if board.someone_won? || board.full?

      alternate_current_player
      clear_screen_and_display_scores_and_board if human_turn?
    end
  end

  def quit_match?
    quit_match = end_match?
    self.already_quit = true if quit_match
    quit_match
  end

  def quit_program?
    prompt = "Would you like to play another match? (y/n)"
    err_msg = "Sorry, you must enter y or n"
    answer = InputValidation.retrieve(prompt, YES_NO, err_msg)

    answer == 'n'
  end

  def reset_match
    match_scores.zeros!
    reset_game
  end

  def reset_game
    board.reset
    clear
  end

  def valid_move_input?(square)
    integer?(square) && board.unmarked_keys.include?(square.to_i)
  end

  def which_player(marker)
    if marker == human.marker
      human
    else
      computer
    end
  end
end

# we'll kick off the game like this
game = TTTGame.new
game.play
