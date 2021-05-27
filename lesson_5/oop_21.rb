require "pry"
require "io/console"

module OutputSpacer
  def spaced_output(text, lines = 1)
    line_space = "\n" * lines

    puts line_space
    puts text
    puts line_space
  end
end

module Hand
  include OutputSpacer

  MAX_VALUE = 21
  LINE_WIDTH = 60
  LINE = "-" * LINE_WIDTH

  def total
    aces, non_aces = cards.partition(&:ace?)
    non_ace_total = non_aces.reduce(0) { |memo, card| memo + card.value }

    total = non_ace_total

    aces.each do |_|
      total += 11

      if total > MAX_VALUE
        total -= 10
      end
    end

    total
  end

  def busted?
    total > MAX_VALUE
  end

  def display_cards
    puts LINE
    puts "#{name} has #{cards.length} cards:"
    cards_str = cards.map(&:to_s).join(', ')
    puts cards_str

    spaced_output("Total value is: #{total}")
    puts LINE
  end

  def reset_hand!
    self.cards = nil
  end

  def hit(card)
    cards << card
  end

  def take_cards(cards)
    self.cards = cards
  end
end

module InputValidation
  YES_NO = ['y', 'yes', 'n', 'no']

  def get_valid_input(prompt, options, error_msg, case_insensitive = true)
    input = ""

    loop do
      puts prompt

      input = gets.chomp.strip

      input.downcase! if case_insensitive
      valid_inputs = case_insensitive ? options.map(&:downcase) : options

      break if valid_inputs.include?(input)
      puts "\n#{error_msg}"
    end

    input
  end
end

class Participant
  include Hand

  attr_reader :cards, :name

  def initialize(name)
    @name = name
  end

  private

  attr_writer :cards
end

class Player < Participant
  def initialize
    @name = determine_name
  end

  def determine_name
    name = nil

    loop do
      puts "Choose player name:"
      name = gets.chomp.strip
      break unless name_error?(name)
      puts "You must enter a valid name."
    end

    name
  end

  private

  def name_error?(input)
    name_error = false

    if input.downcase.include?("dealer")
      display_name_contains_dealer_error
      name_error = true
    elsif input.empty?
      name_error = true
    end

    name_error
  end

  def display_name_contains_dealer_error
    spaced_output("Your name can't have the word \"dealer\" in it!")
  end
end

class Dealer < Participant
  STAY_THRESHOLD = 17

  def display_only_one_card
    puts LINE
    puts "#{name} has #{cards.length} cards: "
    puts "#{cards.first}, and one hidden card"

    spaced_output("Total value is: ???")
    puts LINE
  end

  def too_low?
    total < STAY_THRESHOLD
  end
end

class Deck
  SUITS = ["Clubs", "Diamonds", "Hearts", "Spades"]
  RANKS = ["2", "3", "4", "5", "6", "7", "8", "9", "10", \
           "Jack", "Queen", "King", "Ace"]

  def initialize
    @reference_deck = make_deck
    @deck = reference_deck.dup
  end

  def deal(num_cards = 1)
    dealt = []

    num_cards.times do |_|
      card = deck.sample
      dealt << card
      deck.delete(card)
    end

    if dealt.length == 1
      dealt = dealt.first
    end

    dealt
  end

  # rubocop:disable Lint/UselessAssignment
  def reset!
    deck = reference_deck
  end
  # rubocop:enable Lint/UselessAssignment

  private

  attr_accessor :deck
  attr_reader :reference_deck

  def make_deck
    card_strs = RANKS.product(SUITS)
    deck = []

    card_strs.each do |(rank, suit)|
      deck << Card.new(rank, suit)
    end

    deck
  end
end

class Card
  NON_ACE_VALUES = { "2" => 2, "3" => 3, "4" => 4, "5" => 5, "6" => 6,
                     "7" => 7, "8" => 8, "9" => 9, "10" => 10,
                     "Jack" => 10, "Queen" => 10, "King" => 10 }

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def ace?
    rank == "Ace"
  end

  def to_s
    "#{rank} of #{suit}"
  end

  def value
    return "Ace" if ace?

    NON_ACE_VALUES[rank]
  end

  private

  attr_reader :suit, :rank
end

class TwentyOne
  include InputValidation, OutputSpacer

  STANDARD_LINE_SPACE = 1
  LARGE_LINE_SPACE = 2

  def initialize
    clear_screen_and_display_welcome
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new("Dealer")
  end

  def play
    loop do
      deal_cards
      show_cards_before_dealer_turn
      player_turn
      dealer_turn unless player.busted?
      game_result
      break unless another_game?
      reset
    end

    display_goodbye_message
  end

  private

  attr_accessor :busted
  attr_reader :deck, :player, :dealer

  def another_game?
    continue = get_valid_input("Would you like to play another game?", YES_NO,\
                               "You must enter (y)es or (n)o.")

    continue.downcase.start_with?('y')
  end

  def check_for_player_bust
    return unless player.busted?

    show_all_cards
    spaced_output("You went too high--you busted!")
  end

  def display_dealer_turn_outcome
    if dealer.busted?
      spaced_output("Dealer busts!")
    else
      spaced_output("Dealer stays.")
    end
  end

  def clear
    system "clear"
  end

  def deal_cards
    spaced_output("Dealing initial cards...")

    player.take_cards(deck.deal(2))
    dealer.take_cards(deck.deal(2))
  end

  def dealer_turn
    show_all_cards

    while dealer.too_low?
      dealer.hit(deck.deal)
      puts "Dealer hits!"
      pause_for_user
      show_all_cards
    end

    display_dealer_turn_outcome
  end

  def display_goodbye_message
    puts "Thanks for playing 21! Goodbye!"
  end

  def display_push
    spaced_output("Push! Both hands have the same score.")
  end

  def display_welcome_message
    puts "Welcome to 21! Step right up and play your cards!"
    pause_for_user
  end

  def display_winner(participant)
    winner_str = if participant == player
                   "Congratulations--#{player.name} wins with #{player.total}!"
                 else
                   "Dealer wins with #{dealer.total}. Better luck next time!"
                 end

    spaced_output(winner_str)
  end

  def game_result
    if push?
      display_push
    else
      display_winner(higher_valid_total)
    end
  end

  def clear_screen_and_display_welcome
    clear
    display_welcome_message
  end

  def higher_valid_total
    if player.busted?
      dealer
    elsif dealer.busted? || (player.total > dealer.total)
      player
    else
      dealer
    end
  end

  def pause_for_user
    spaced_output("Press any key to continue...")
    STDIN.getch
  end

  def player_choice
    prompt = "Would you like to (h)it or (s)tay?"
    choice = get_valid_input(prompt, ['h', 'hit', 's', 'stay'],
                             "You must enter (h)it or (s)tay!")
    choice.downcase
  end

  def player_hits
    player.hit(deck.deal)
    puts "You hit!"
    pause_for_user
    clear
    show_cards_before_dealer_turn
  end

  def player_stays
    puts
    puts "You stay at #{player.total}"
    pause_for_user
  end

  def player_turn
    loop do
      check_for_player_bust
      break if player.busted?

      choice = player_choice

      break unless choice.start_with?('h')
      player_hits
    end

    player_stays unless player.busted?
  end

  def push?
    player.total == dealer.total
  end

  def reset
    spaced_output("Let's play again!")
    deck.reset!
    player.reset_hand!
    dealer.reset_hand!
  end

  def show_all_cards
    clear
    dealer.display_cards
    player.display_cards
  end

  def show_cards_before_dealer_turn
    clear
    dealer.display_only_one_card
    player.display_cards
  end
end

TwentyOne.new.play
