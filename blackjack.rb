require 'pry'
# ============================================================================== Pseudocode Algorithm

# 1. Prepare the decks. Generate 52 unique cards. Repeat for cases with more than
#    1 deck. Shuffle all the cards.
# 2. Allow user to place bets, knowing that wins pay 1:1 and blackjack pays 2:1 
#    on one deck and 3:1 on more than one deck.
# 3. Deal 2 cards to each player. 
# 4. Allow player to either hit (be dealt another card) or stay (no more cards)
#    until all players are either "busted" or satisfied with their position. See
#    rules of card addition.
# 5. Dealer gets two cards and must hit until a total of at least 17. Dealer can
#    choose to stay or hit past 17, but aims for the highest hand without breaking
#    a total card sum of 21. 
# 6. When dealer is satisfied, any player with a smaller card total loses their
#    entire bet. Any player with equal sum neither loses nor gains ("push"). Any
#    player with a greater sum wins 1x more than their bet. Any player with 
#    blackjack wins 2x or 3x more than their bet depending on the number of decks.
# 7. Repeat steps 3 - 6 until the deck(s) is empty. At which time, repeat step 1.
# 8. Game is over when the player either has no more money to bet or walks away.

# Card addition rules
# - An ace is worth either 1 or 11, whichever gets closer to 21 without going over
# - Face cards (K, Q, J) are worth 10
# - All number cards are worth their number, regardless of suit

# ============================================================================== Method Definitions

def display_header # <= nil
  system("clear")
  puts "Let's Play BlackJack"
  puts "===================="
  puts
end # => nil

def format_player_status(game_hash, player_number) # <= Hash
  example_hand_string = ""
  example_hand = game_hash[:dealer_deck].sample(3)
  
  example_hand.each do |card|
    example_hand_string << "#{card} "
  end
  
  hand_total = (total_of_hand example_hand)[0]
  hand_total = "BUSTED" if hand_total > 21
  hand_total = "BLACKJACK" if hand_total == 21
  
  puts "#{game_hash[:names][player_number]} ($#{game_hash[:wallets][player_number]}) | Bet $#{game_hash[:current_bets][player_number]}"
  puts "-----------------------"
  puts "#{example_hand_string} (#{hand_total})"
  puts ""
end # => nil

def game_setup # <= nil
  display_header
  game_data = {}
  player_names = []
  
  game_data[:decks] = (prompt "Choose Difficulty: 1 (easy) - 5 (hard)").to_i
  
  player_names << (prompt "What is your name?") 
  player_names << File.readlines("names.txt").sample(rand(4)).map {|name| name.strip.capitalize}
  game_data[:names] = player_names.flatten
  
  wallets = []
  hands = []
  bets = []
  game_data[:names].count.times { wallets << 100; hands << []; bets << 0 }
  game_data[:wallets] = wallets
  game_data[:current_hands] = hands
  game_data[:current_bets] = bets
  
  game_data[:dealer_deck] = prepare_decks game_data[:decks]
  game_data[:dealer_hand] = []
  
  game_data
end # => Hash

def total_with_aces(subtotal, number_of_aces_in_hand) # <= Integer, Integer
  return 100 if (subtotal + number_of_aces_in_hand > 21)
  case number_of_aces_in_hand
    when 0
      total = subtotal
    when 1
      total = (subtotal + 11 > 21) ? (subtotal + 1) : (subtotal + 11)
    when 2
      total = (subtotal + 12 > 21) ? (subtotal + 2) : (subtotal + 12)
    when 3
      total = (subtotal + 13 > 21) ? (subtotal + 3) : (subtotal + 13)
    when 4
      total = (subtotal + 14 > 21) ? (subtotal + 4) : (subtotal + 14)
  end
  total
end # => Integer

def total_of_hand(hand) # <= Array
  total = 0
  aces = ["[♠ A]","[♣ A]","[♥ A]","[♦ A]"]
  indices_of_aces = hand.each_index.select { |i| aces.include? hand[i] }
  
  hand.each do |card|
    face = card.split("")[3]
    value = face.to_i if %w(1 2 3 4 5 6 7 8 9).include? face
    value = 10 if %w(Q K J).include? face
    value = 0 if face == "A"
    total += value
  end
  total = total_with_aces(total, indices_of_aces.count)
  return total, hand
end # => Integer, Array

def prepare_decks(number_of_decks) # <= Integer
  suits = ["♠","♣","♥","♦"]
  values = %w(1 2 3 4 5 6 7 8 9 J Q K A)
  deck = []
  
  suits.each do |suit|
    values.each do |value|
      deck << "[#{suit} #{value}]"
    end
  end
  
  (deck *= number_of_decks).shuffle
end # => Array

def prompt(msg) # <= String
  say msg
  gets.chomp
end # => String

def say(msg) # <= String
  puts " => #{msg}"
end # => nil

def update_playing_table(game_hash) # <= Hash
  display_header
  game_hash[:names].each_index do |index|
    format_player_status game_hash, index
  end
end # => nil

# ============================================================================== Game Logic

game_hash = game_setup
update_playing_table game_hash
