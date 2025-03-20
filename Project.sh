#!/bin/bash
# Global Variables for managing game
declare -a shapes=("Circle" "Star" "Umbrella" "Triangle")
Player_Score=0
Computer_Score=0
Leaderboard_File="leaderboard.txt"
Timer=8  # Default for Easy mode game

# ASCII Art Definitions
declare -A ASCII_ART=
(
    ["Circle"]="
        o  o              
     o        o
    o          o
    o          o
     o        o
        o  o
"
    ["Star"]="
     __/\__
     \    /
     /_  _\ 
       \/
"
    ["Umbrella"]="
        _/\_
      _/    \_
    _/        \_
   /____________\ 
         |
         |
         |
       |_|
"
    ["Triangle"]="
        *
       * *
      *   *
     *     *
    *********
"
)
# Introduction text
Introduction='
||============================================================================================||
||                           Dalgona Challenge - Shell Script Game                            ||
||                             Group Members: 23F-3074, 23F-3033                              ||
||       Features: Single Player, VS Computer, Multiplayer, Difficulty Levels, Leaderboard    ||
||============================================================================================||'

# Function to display text with a delay
display_with_delay() {
    local text=$1
    local delay=$2
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep $delay
    done
    echo
}

# =============================================================================
# Function: select_difficulty()
# Description: Let the user choose the game difficulty (timer).
# =============================================================================
select_difficulty()
{
	cat<<MNR
	================================
	#   Choose Difficulty Level    #
	================================
	||     1. Easy (8 sec.)       ||
	||     2. Medium (6 sec.)     ||
	||     3. Hard (4 sec.)       ||
	================================
MNR
	read -p "-=> Your Choice : " choice
    case $choice in
        1) Timer=8 ;;
        2) Timer=6 ;;
        3) Timer=4 ;;
        *) echo "Invalid choice. Defaulting to Easy." ;;
    esac
}

# =============================================================================
# Function: display_ascii_shape()
# Description: Display ASCII art for a given shape.
# Parameters: $1 - Shape name
# =============================================================================
display_ascii_shape() {
    echo "Here is your challenge shape:"
    echo "${ASCII_ART[$1]}"
}

# =============================================================================
# Function: select_random_shape()
# Description: Randomly select a shape from the predefined list.
# Returns: A shape name as a string.
# =============================================================================
select_random_shape() {
    local index=$((RANDOM % 4))
    echo "${shapes[$index]}"
}

# =============================================================================
# Function: single_player_mode()
# Description: Single player gameplay with dynamic timer and attempts.
# =============================================================================
single_player_mode() {
    read -p "Enter your name: " player_name
    local shape=$(select_random_shape)
    display_ascii_shape "$shape"
    local attempts=3
    local guessed=0

    while [[ $attempts -gt 0 && $guessed -eq 0 ]]; do
        echo -e "\n$player_name, enter the shape name (Attempts left: $attempts):"
        read -t $timer -p "> " guess
        if [[ $? -ne 0 ]]; then
            echo -e "\nTime's up!"
            break
        fi
        if [[ "${guess,,}" == "${shape,,}" ]]; then
            echo "Correct! You earned 10 points."
            Player_Score=$((Player_Score + 10))
            guessed=1
        else
            echo "Wrong guess!"
            attempts=$((attempts - 1))
        fi
    done

    if [[ $guessed -eq 0 ]]; then
        echo -e "\nThe correct answer was: $shape"
    fi
}

# =============================================================================
# Function: vs_computer_mode()
# Description: Player vs Computer mode with dynamic timer.
# =============================================================================
vs_computer_mode() {
    read -p "Enter your name: " player_name
    local shape=$(select_random_shape)
    display_ascii_shape "$shape"

    # Player's turn
    echo -e "\n$player_name's turn ($Timer seconds):"
    read -t $Timer -p "> " player_guess
    if [[ $? -ne 0 ]]; then
        echo -e "\nTime's up!"
        player_guess=""
    fi
    if [[ "${player_guess,,}" == "${shape,,}" ]]; then
        echo "Correct! $player_name earns 10 points."
        Player_Score=$((Player_Score + 10))
    else
        echo "Incorrect guess."
    fi

    # Computer's turn
    local computer_guess=${shapes[$((RANDOM % 4))]}
    echo -e "\nComputer guess : $computer_guess"
    if [[ "$computer_guess" == "$shape" ]]; then
        echo "Computer earns 10 points."
        Computer_Score=$((Computer_Score + 10))
    else
        echo "Computer failed !"
    fi

    echo -e "\nCorrect Answer : $shape"
}

# Function : multiplayer_mode() & working : Multiplayer mode with two players and dynamic timer.
multiplayer_mode() {
    read -p "Enter Player 1's name : " player1
    read -p "Enter Player 2's name : " player2
    local p1_score=0
    local p2_score=0
    local round=1
    local play_again="y"

    while [[ "$play_again" == "y" ]]; do
        local shape=$(select_random_shape)
        echo -e "\n=== Round $round ==="
        display_ascii_shape "$shape"

        # Player 1's turn
        echo -e "\n$player1's turn ($timer seconds):"
        read -t $timer -p "> " guess1
        if [[ $? -ne 0 ]]; then
            echo -e "\nTime's up!"
            guess1=""
        fi

        # Player 2's turn
        echo -e "\n$player2's turn ($timer seconds):"
        read -t $timer -p "> " guess2
        if [[ $? -ne 0 ]]; then
            echo -e "\nTime's up!"
            guess2=""
        fi

        # Check guesses
        if [[ "${guess1,,}" == "${shape,,}" ]]; then
            echo "$player1 guessed correctly! +10 points."
            p1_score=$((p1_score + 10))
        else
            echo "$player1's guess was incorrect."
        fi

        if [[ "${guess2,,}" == "${shape,,}" ]]; then
            echo "$player2 guessed correctly! +10 points."
            p2_score=$((p2_score + 10))
        else
            echo "$player2's guess was incorrect."
        fi

        echo -e "\nCorrect answer: $shape"
        echo "Scores: $player1: $p1_score | $player2: $p2_score"
        read -p "Play another round? (y/n): " play_again
        round=$((round + 1))
    done

    echo -e "\n=== Final Scores ==="
    echo "$player1: $p1_score"
    echo "$player2: $p2_score"
}

# =============================================================================
# Function: update_leaderboard()
# Description: Append the player's score to the leaderboard file.
# =============================================================================
update_leaderboard() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $player_name: Score $player_score" >> "$leaderboard_file"
    echo "Score saved to leaderboard."
}

# =============================================================================
# Function: main_menu (), & Display the main menu and handle user input.
# =============================================================================
main_menu() {
    while true; do
	cat<<Printing
    	"================================================="
	"||      Welcome to the Dalgona Challenge       ||"
	"||        1. Single Player Mode                ||"
        "||        2. VS Computer Mode                  ||"
        "||        3. Multiplayer Mode                  ||"
        "||        4. View Leaderboard                  ||"
        "||        5. Exit                              ||"
        "================================================="
Printing
        read -p "   -=> Your Choice : " choice

        case $choice in
            1) single_player_mode ;;
            2) vs_computer_mode ;;
            3) multiplayer_mode ;;
            4) [[ -f "$leaderboard_file" ]] && cat "$leaderboard_file" || echo "No scores yet." ;;
            5) update_leaderboard
               echo "Goodbye !"
               exit 0 ;;
            *) echo "Invalid option." ;;
        esac
    done
}
# Start the Game

display_with_delay "$Introduction" 0.05
select_difficulty
main_menu