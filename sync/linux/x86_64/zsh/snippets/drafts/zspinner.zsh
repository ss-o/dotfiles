#!/usr/bin/env zsh

local -A _revolver_spinners
_revolver_spinners=(
  'dots' '0.08 ⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏'
  'dots2' '0.08 ⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷'
  'dots3' '0.08 ⠋ ⠙ ⠚ ⠞ ⠖ ⠦ ⠴ ⠲ ⠳ ⠓'
  'dots4' '0.08 ⠄ ⠆ ⠇ ⠋ ⠙ ⠸ ⠰ ⠠ ⠰ ⠸ ⠙ ⠋ ⠇ ⠆'
  'dots5' '0.08 ⠋ ⠙ ⠚ ⠒ ⠂ ⠂ ⠒ ⠲ ⠴ ⠦ ⠖ ⠒ ⠐ ⠐ ⠒ ⠓ ⠋'
  'dots6' '0.08 ⠁ ⠉ ⠙ ⠚ ⠒ ⠂ ⠂ ⠒ ⠲ ⠴ ⠤ ⠄ ⠄ ⠤ ⠴ ⠲ ⠒ ⠂ ⠂ ⠒ ⠚ ⠙ ⠉ ⠁'
  'dots7' '0.08 ⠈ ⠉ ⠋ ⠓ ⠒ ⠐ ⠐ ⠒ ⠖ ⠦ ⠤ ⠠ ⠠ ⠤ ⠦ ⠖ ⠒ ⠐ ⠐ ⠒ ⠓ ⠋ ⠉ ⠈'
  'dots8' '0.08 ⠁ ⠁ ⠉ ⠙ ⠚ ⠒ ⠂ ⠂ ⠒ ⠲ ⠴ ⠤ ⠄ ⠄ ⠤ ⠠ ⠠ ⠤ ⠦ ⠖ ⠒ ⠐ ⠐ ⠒ ⠓ ⠋ ⠉ ⠈ ⠈'
  'dots9' '0.08 ⢹ ⢺ ⢼ ⣸ ⣇ ⡧ ⡗ ⡏'
  'dots10' '0.08 ⢄ ⢂ ⢁ ⡁ ⡈ ⡐ ⡠'
  'dots11' '0.1 ⠁ ⠂ ⠄ ⡀ ⢀ ⠠ ⠐ ⠈'
  'dots12' '0.08 "⢀⠀" "⡀⠀" "⠄⠀" "⢂⠀" "⡂⠀" "⠅⠀" "⢃⠀" "⡃⠀" "⠍⠀" "⢋⠀" "⡋⠀" "⠍⠁" "⢋⠁" "⡋⠁" "⠍⠉" "⠋⠉" "⠋⠉" "⠉⠙" "⠉⠙" "⠉⠩" "⠈⢙" "⠈⡙" "⢈⠩" "⡀⢙" "⠄⡙" "⢂⠩" "⡂⢘" "⠅⡘" "⢃⠨" "⡃⢐" "⠍⡐" "⢋⠠" "⡋⢀" "⠍⡁" "⢋⠁" "⡋⠁" "⠍⠉" "⠋⠉" "⠋⠉" "⠉⠙" "⠉⠙" "⠉⠩" "⠈⢙" "⠈⡙" "⠈⠩" "⠀⢙" "⠀⡙" "⠀⠩" "⠀⢘" "⠀⡘" "⠀⠨" "⠀⢐" "⠀⡐" "⠀⠠" "⠀⢀" "⠀⡀"'
  'line' '0.13 - \\ | /'
  'line2' '0.1 ⠂ - – — – -'
  'pipe' '0.1 ┤ ┘ ┴ └ ├ ┌ ┬ ┐'
  'simpleDots' '0.4 ".  " ".. " "..." "   "'
  'simpleDotsScrolling' '0.2 ".  " ".. " "..." " .." "  ." "   "'
  'star' '0.07 ✶ ✸ ✹ ✺ ✹ ✷'
  'star2' '0.08 + x *'
  'flip' "0.07 _ _ _ - \` \` ' ´ - _ _ _"
  'hamburger' '0.1 ☱ ☲ ☴'
  'growVertical' '0.12 ▁ ▃ ▄ ▅ ▆ ▇ ▆ ▅ ▄ ▃'
  'growHorizontal' '0.12 ▏ ▎ ▍ ▌ ▋ ▊ ▉ ▊ ▋ ▌ ▍ ▎'
  'balloon' '0.14 " " "." "o" "O" "@" "*" " "'
  'balloon2' '0.12 . o O ° O o .'
  'noise' '0.14 ▓ ▒ ░'
  'bounce' '0.1 ⠁ ⠂ ⠄ ⠂'
  'boxBounce' '0.12 ▖ ▘ ▝ ▗'
  'boxBounce2' '0.1 ▌ ▀ ▐ ▄'
  'triangle' '0.05 ◢ ◣ ◤ ◥'
  'arc' '0.1 ◜ ◠ ◝ ◞ ◡ ◟'
  'circle' '0.12 ◡ ⊙ ◠'
  'squareCorners' '0.18 ◰ ◳ ◲ ◱'
  'circleQuarters' '0.12 ◴ ◷ ◶ ◵'
  'circleHalves' '0.05 ◐ ◓ ◑ ◒'
  'squish' '0.1 ╫ ╪'
  'toggle' '0.25 ⊶ ⊷'
  'toggle2' '0.08 ▫ ▪'
  'toggle3' '0.12 □ ■'
  'toggle4' '0.1 ■ □ ▪ ▫'
  'toggle5' '0.1 ▮ ▯'
  'toggle6' '0.3 ဝ ၀'
  'toggle7' '0.08 ⦾ ⦿'
  'toggle8' '0.1 ◍ ◌'
  'toggle9' '0.1 ◉ ◎'
  'toggle10' '0.1 ㊂ ㊀ ㊁'
  'toggle11' '0.05 ⧇ ⧆'
  'toggle12' '0.12 ☗ ☖'
  'toggle13' '0.08 = * -'
  'arrow' '0.1 ← ↖ ↑ ↗ → ↘ ↓ ↙'
  'arrow2' '0.12 ▹▹▹▹▹ ▸▹▹▹▹ ▹▸▹▹▹ ▹▹▸▹▹ ▹▹▹▸▹ ▹▹▹▹▸'
  'bouncingBar' '0.08 "[    ]" "[   =]" "[  ==]" "[ ===]" "[====]" "[=== ]" "[==  ]" "[=   ]"'
  'bouncingBall' '0.08 "( ●    )" "(  ●   )" "(   ●  )" "(    ● )" "(     ●)" "(    ● )" "(   ●  )" "(  ●   )" "( ●    )" "(●     )"'
  'pong' '0.08 "▐⠂       ▌" "▐⠈       ▌" "▐ ⠂      ▌" "▐ ⠠      ▌" "▐  ⡀     ▌" "▐  ⠠     ▌" "▐   ⠂    ▌" "▐   ⠈    ▌" "▐    ⠂   ▌" "▐    ⠠   ▌" "▐     ⡀  ▌" "▐     ⠠  ▌" "▐      ⠂ ▌" "▐      ⠈ ▌" "▐       ⠂▌" "▐       ⠠▌" "▐       ⡀▌" "▐      ⠠ ▌" "▐      ⠂ ▌" "▐     ⠈  ▌" "▐     ⠂  ▌" "▐    ⠠   ▌" "▐    ⡀   ▌" "▐   ⠠    ▌" "▐   ⠂    ▌" "▐  ⠈     ▌" "▐  ⠂     ▌" "▐ ⠠      ▌" "▐ ⡀      ▌" "▐⠠       ▌"'
  'shark' '0.12 "▐|\\____________▌" "▐_|\\___________▌" "▐__|\\__________▌" "▐___|\\_________▌" "▐____|\\________▌" "▐_____|\\_______▌" "▐______|\\______▌" "▐_______|\\_____▌" "▐________|\\____▌" "▐_________|\\___▌" "▐__________|\\__▌" "▐___________|\\_▌" "▐____________|\\▌" "▐____________/|▌" "▐___________/|_▌" "▐__________/|__▌" "▐_________/|___▌" "▐________/|____▌" "▐_______/|_____▌" "▐______/|______▌" "▐_____/|_______▌" "▐____/|________▌" "▐___/|_________▌" "▐__/|__________▌" "▐_/|___________▌" "▐/|____________▌"'
)

###
# Output usage information and exit
###
function _revolver_usage() {
  echo "\033[0;33mUsage:\033[0;m"
  echo "  revolver [options] <command> <message>"
  echo
  echo "\033[0;33mOptions:\033[0;m"
  echo "  -h, --help         Output help text and exit"
  echo "  -v, --version      Output version information and exit"
  echo "  -s, --style        Set the spinner style"
  echo
  echo "\033[0;33mCommands:\033[0;m"
  echo "  start <message>    Start the spinner"
  echo "  update <message>   Update the message"
  echo "  stop               Stop the spinner"
  echo "  demo               Display an demo of each style"
}

###
# The main revolver process, which contains the loop
###
function _revolver_process() {
  local dir statefile state msg pid="$1" spinner_index=0

  # Find the directory and load the statefile
  dir=${REVOLVER_DIR:-"${ZDOTDIR:-$HOME}/.revolver"}
  statefile="$dir/$pid"

  # The frames that, when animated, will make up
  # our spinning indicator
  frames=(${(@z)_revolver_spinners[$style]})
  interval=${(@z)frames[1]}
  shift frames

  # Create a never-ending loop
  while [[ 1 -eq 1 ]]; do
    # If the statefile has been removed, exit the script
    # to prevent it from being orphaned
    if [[ ! -f $statefile ]]; then
      exit 1
    fi

    # Check for the existence of the parent process
    $(kill -s 0 $pid 2&>/dev/null)

    # If process doesn't exist, exit the script
    # to prevent it from being orphaned
    if [[ $? -ne 0 ]]; then
      exit 1
    fi

    # Load the current state, and parse it to get
    # the message to be displayed
    state=($(cat $statefile))

    msg="${(@)state:1}"

    # Output the current spinner frame, and add a
    # slight delay before the next one
    _revolver_spin
    sleep ${interval:-"0.1"}
  done
}

###
# Output the spinner itself, along with a message
###
function _revolver_spin() {
  local dir statefile state pid frame

  # ZSH arrays start at 1, so we need to bump the index if it's 0
  if [[ $spinner_index -eq 0 ]]; then
    spinner_index+=1
  fi

  # Calculate the screen width
  lim=$(tput cols)

  # Clear the line and move the cursor to the start
  printf ' %.0s' {1..$lim}
  echo -n "\r"

  # Echo the current frame and message, and overwrite
  # the rest of the line with white space
  msg="\033[0;38;5;242m${msg}\033[0;m"
  frame="${${(@z)frames}[$spinner_index]//\"}"
  printf '%*.*b' ${#msg} $lim "$frame $msg$(printf '%0.1s' " "{1..$lim})"

  # Return to the beginning of the line
  echo -n "\r"

  # Set the spinner index to the next frame
  spinner_index=$(( $(( $spinner_index + 1 )) % $(( ${#frames} + 1 )) ))
}

###
# Stop the current spinner process
###
function _revolver_stop() {
  local dir statefile state pid

  # Find the directory and load the statefile
  dir=${REVOLVER_DIR:-"${ZDOTDIR:-$HOME}/.revolver"}
  statefile="$dir/$PPID"

  # If the statefile does not exist, raise an error.
  # The spinner process itself performs the same check
  # and kills itself, so it should never be orphaned
  if [[ ! -f $statefile ]]; then
    echo '\033[0;31mRevolver process could not be found\033[0;m'
    exit 1
  fi

  # Get the current state, and parse it to find the PID
  # of the spinner process
  state=($(cat $statefile))
  pid="$state[1]"

  # Clear the line and move the cursor to the start
  printf ' %.0s' {1..$(tput cols)}
  echo -n "\r"

  # If a PID has been found, kill the process
  [[ ! -z $pid ]] && kill "$pid" > /dev/null
  unset pid

  # Remove the statefile
  rm $statefile
}

###
# Update the message being displayed
function _revolver_update() {
  local dir statefile state pid msg="$1"

  # Find the directory and load the statefile
  dir=${REVOLVER_DIR:-"${ZDOTDIR:-$HOME}/.revolver"}
  statefile="$dir/$PPID"

  # If the statefile does not exist, raise an error.
  # The spinner process itself performs the same check
  # and kills itself, so it should never be orphaned
  if [[ ! -f $statefile ]]; then
    echo '\033[0;31mRevolver process could not be found\033[0;m'
    exit 1
  fi

  # Get the current state, and parse it to find the PID
  # of the spinner process
  state=($(cat $statefile))
  pid="$state[1]"

  # Clear the line and move the cursor to the start
  printf ' %.0s' {1..$(tput cols)}
  echo -n "\r"

  # Echo the new message to the statefile, to be
  # picked up by the spinner process
  echo "$pid $msg" >! $statefile
}

###
# Create a new spinner with the specified message
###
function _revolver_start() {
  local dir statefile msg="$1"
