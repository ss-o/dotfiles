#!/bin/bash
#
# Author : Jonathan Sanfilippo
# Date: Jul 2023
# Version 2.2: Clean
#

B="B"
cache="$(du -sk /var/cache/pacman/pkg/ | awk '{ print $1 }')"
lib=$(du -sk /var/lib/pacman/ | awk '{ print $1 }')
home_cache=$(du -sk "${HOME}"/.cache/ | awk '{ print $1 }')
trash=$(du -sk "${HOME}"/.local/share/Trash/files/ | awk '{ print $1 }')
cache2=$(du -sh /var/cache/pacman/pkg/ | awk '{ print $1 }')
lib2=$(du -sh /var/lib/pacman/ | awk '{ print $1 }')
home_cache2=$(du -sh "${HOME}"/.cache/ | awk '{ print $1 }')
trash2=$(du -sh "${HOME}"/.local/share/Trash/files/ | awk '{ print $1 }')
total=$(echo "${cache} + ${lib} + ${home_cache} + ${trash}" | bc)

if (($(echo "${total} < 1024" | bc -l))); then
  unit="KB"
  total=$(echo "${total}" | awk '{printf "%.2f\n", $1}')
elif (($(echo "${total} < 1048576" | bc -l))); then
  unit="MB"
  total=$(echo "scale=2; ${total}/1024" | bc -l)
else
  unit="GB"
  total=$(echo "scale=2; ${total}/(1024*1024)" | bc -l)
fi

# Show confirmation message
show_confirmation() {
  whiptail --title "Confirm" --yesno "$1" 0 0
  return $?
}

# Show information message
show_message() {
  whiptail --title "Info" --msgbox "$1" 0 0
}

# Show main menu
while true; do
  choice=$(whiptail --title "Clean v2.2" --menu "Please select an option:" 0 60 0 \
    "1" "Check recoverable space" \
    "2" "Orphans Packages" \
    "3" "Remove cache that are no longer installed" \
    "4" "Remove all packages cache" \
    "5" "Remove home cache and Trash files" \
    "6" "All in One!" \
    "9" "Exit" \
    3>&1 1>&2 2>&3)

  # Check if choice is empty (user pressed Cancel)
  if [[ -z ${choice} ]]; then
    echo "Exiting.."
    exit 0
  fi

  case ${choice} in
  1)
    show_message "Current space between home cache: ${home_cache2}${B}, packages cache: ${cache2}${B}, library pacman: ${lib2}${B}, and trash: ${trash2}${B}, total: ${total}${unit}"
    ;;
  2)
    if pacman -Qdt &>/dev/null; then
      if show_confirmation "Orphaned packages and possible dependencies found, show them?"; then
        pacman -Qdt | awk '{print $1}' | sudo pacman -Rns -
      else
        show_message "Cancellation in progress..."
      fi
    else
      show_message "No obsolete packages to remove."
    fi
    ;;
  3)
    if show_confirmation "Are you sure you want to remove no longer installed packages cache: ${cache2}${B}, library pacman: ${lib2}${B}?"; then
      yes | sudo pacman -Sc
      show_message "Package cache cleanup complete."
    else
      show_message "Package cache cleanup cancelled."
    fi
    ;;
  4)
    if show_confirmation "Are you sure you want to remove all installed packages cache: ${cache2}${B}, library pacman: ${lib2}${B}?"; then
      yes | sudo pacman -Scc
      show_message "Package cache cleanup complete."
    else
      show_message "Package cache cleanup cancelled."
    fi
    ;;
  5)
    if show_confirmation "Are you sure you want to remove home cache: ${home_cache2}${B} and Trash files: ${trash2}${B}?"; then
      rm -rf "${HOME}"/.cache/* "${HOME}"/.local/share/Trash/files/*
      show_message "Home cache and trash file cleanup complete."
    else
      show_message "Home cache and trash file cleanup cancelled."
    fi
    ;;
  6)
    if show_confirmation "Are you sure you want to remove all system caches and trash files, total: ${total}${unit}?"; then
      yes | sudo pacman -Scc
      rm -rf "${HOME}"/.cache/*
      rm -rf "${HOME}"/.local/share/Trash/files/*
      show_message "System cache and trash file cleanup complete."
    else
      show_message "System cache and trash file cleanup cancelled."
    fi
    ;;
  9)
    show_message "Goodbye!"
    clear
    exit 0
    ;;
  *)
    show_message "No valid option, please try again!"
    ;;
  esac
done
