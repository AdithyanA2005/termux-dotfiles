#!/bin/bash

# Termux Interactive Setup
set -e

# -----------------------------------------------
# Style
# -----------------------------------------------
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
GRAY='\033[0;90m'
RESET='\033[0m'

step_num=0
total_steps=0

header() {
  echo ""
  echo -e "${BOLD}=========================================${RESET}"
  echo -e "${BOLD}        Termux Initial Setup${RESET}"
  echo -e "${BOLD}=========================================${RESET}"
  echo ""
}

separator() {
  echo -e "${GRAY}-----------------------------------------${RESET}"
}

done_msg() {
  echo -e "${GREEN}[✓]${RESET} $1"
}

skipped_msg() {
  echo -e "${GRAY}[–]${RESET} $1"
}

step_msg() {
  echo -e "${BOLD}[$step_num/$total_steps]${RESET} $1"
}

# -----------------------------------------------
# Status Checks
# -----------------------------------------------
check_git() {
  local name email

  if ! command -v git >/dev/null 2>&1; then
    echo -e "  [Git]       ${YELLOW}git not installed${RESET}"
    return 0
  fi

  name=$(git config --global user.name 2>/dev/null || true)
  email=$(git config --global user.email 2>/dev/null || true)
  if [ -n "$name" ] && [ -n "$email" ]; then
    echo -e "  [Git]       user.name: ${GREEN}${name}${RESET} | email: ${GREEN}${email}${RESET}"
  else
    echo -e "  [Git]       ${YELLOW}not configured${RESET}"
  fi
}

check_mirror() {
  echo -e "  [Mirror]    Run to configure package mirrors"
}

check_update() {
  echo -e "  [Update]    Updates all system packages"
}

check_packages() {
  local pkgs=(neovim curl git openssh stow bat which eza tmux fzf zoxide)
  local installed=()
  local missing=()
  for pkg in "${pkgs[@]}"; do
    if dpkg -s "$pkg" &>/dev/null; then
      installed+=("$pkg")
    else
      missing+=("$pkg")
    fi
  done
  echo -n "  [Packages]  "
  if [ ${#installed[@]} -gt 0 ]; then
    echo -ne "${GREEN}✓ ${installed[*]}${RESET}"
  fi
  if [ ${#missing[@]} -gt 0 ]; then
    [ ${#installed[@]} -gt 0 ] && echo -n " | "
    echo -ne "${YELLOW}✗ ${missing[*]}${RESET}"
  fi
  echo ""
}

check_ssh() {
  local key="$HOME/.ssh/id_ed25519"
  if [ -f "$key" ]; then
    echo -e "  [SSH]       ${GREEN}✓ Key found${RESET}: $key"
  else
    echo -e "  [SSH]       ${YELLOW}✗ No key found${RESET}"
  fi
}

check_stow() {
  local stowed=true
  if [ ! -L "$HOME/.bashrc" ]; then
    stowed=false
  fi
  if [ ! -L "$HOME/.termux/termux.properties" ]; then
    stowed=false
  fi
  if [ "$stowed" = true ]; then
    echo -e "  [Dotfiles]  ${GREEN}✓ Stowed${RESET}"
  else
    echo -e "  [Dotfiles]  ${YELLOW}✗ Not stowed${RESET}"
  fi
}

check_font() {
  if [ -f "$HOME/.termux/font.ttf" ]; then
    echo -e "  [Font]      ${GREEN}✓ Set${RESET}"
  else
    echo -e "  [Font]      ${YELLOW}✗ Not set${RESET}"
  fi
}

# -----------------------------------------------
# Menu
# -----------------------------------------------
show_menu() {
  separator
  echo -e "${BOLD}Select steps to run${RESET}"
  separator
  echo "  1) Configure git identity"
  echo "  2) Select package mirror"
  echo "  3) Update system packages"
  echo "  4) Install core packages"
  echo "  5) Setup SSH key"
  echo "  6) Stow dotfiles"
  echo "  7) Set terminal font"
  echo "  8) Run all"
  separator
  echo -n "Choice (e.g., 1 3 4): "
}

add_step() {
  local candidate="$1"
  local existing

  for existing in "${steps[@]}"; do
    if [ "$existing" = "$candidate" ]; then
      return 0
    fi
  done

  steps+=("$candidate")
}

# -----------------------------------------------
# Step Execution
# -----------------------------------------------
run_git() {
  local name email

  if ! command -v git >/dev/null 2>&1; then
    step_msg "Installing git..."
    pkg install -y git
  fi

  name=$(git config --global user.name 2>/dev/null || true)
  email=$(git config --global user.email 2>/dev/null || true)

  if [ -n "$name" ] && [ -n "$email" ]; then
    git config --global push.autoSetupRemote true
    git config --global color.ui auto
    skipped_msg "Git identity already set — keeping existing name/email"
    done_msg "Git defaults configured"
    return 0
  fi

  step_msg "Configuring git identity..."
  while [ -z "${git_user:-}" ]; do
    read -rp "  Enter git username: " git_user
  done
  while [ -z "${git_email:-}" ]; do
    read -rp "  Enter git email: " git_email
  done
  git config --global user.name "$git_user"
  git config --global user.email "$git_email"
  git config --global push.autoSetupRemote true
  git config --global color.ui auto
  done_msg "Git identity configured"
}

run_mirror() {
  step_msg "Opening mirror selection..."
  echo "  Follow the prompts in the pop-up:"
  echo "    1. Leave 'Main repository' selected, press Enter"
  echo "    2. Arrow down to 'Mirrors in Asia'"
  echo "    3. Press SPACEBAR to select"
  echo "    4. TAB to < OK >, press Enter"
  read -rp "  Press [ENTER] to continue..."
  termux-change-repo
  done_msg "Mirror configured"
}

run_update() {
  step_msg "Updating system packages..."
  pkg update -y
  pkg upgrade -y
  done_msg "System packages updated"
}

run_packages() {
  local pkgs=(neovim curl git openssh stow bat which eza tmux fzf zoxide)
  local already=()
  local installed=()

  step_msg "Installing core packages..."

  for pkg in "${pkgs[@]}"; do
    if dpkg -s "$pkg" &>/dev/null; then
      already+=("$pkg")
    else
      pkg install -y "$pkg"
      installed+=("$pkg")
    fi
  done

  if [ ${#installed[@]} -gt 0 ]; then
    done_msg "Installed: ${installed[*]}"
  fi
  if [ ${#already[@]} -gt 0 ]; then
    skipped_msg "Already installed: ${already[*]}"
  fi
}

run_ssh() {
  local key="$HOME/.ssh/id_ed25519"

  if [ -f "$key" ]; then
    skipped_msg "SSH key already exists — skipping"
    return 0
  fi

  step_msg "Generating SSH key pair..."
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  ssh-keygen -t ed25519 -C "Termux Android" -f "$key"
  done_msg "SSH key generated"
  echo ""
  echo -e "${BOLD}Your public key:${RESET}"
  cat "${key}.pub"
  separator
  echo "  Copy this to your server's authorized_keys"
  separator
}

run_stow() {
  local stowed=true
  if [ ! -L "$HOME/.bashrc" ]; then
    stowed=false
  fi
  if [ ! -L "$HOME/.termux/termux.properties" ]; then
    stowed=false
  fi

  if [ "$stowed" = true ]; then
    step_msg "Dotfiles already stowed — restowing..."
    stow -R .
    termux-reload-settings
    done_msg "Dotfiles restowed"
  else
    step_msg "Stowing dotfiles..."
    stow .
    termux-reload-settings
    done_msg "Dotfiles stowed"
  fi
}

run_font() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local fonts_dir="$script_dir/fonts"

  if [ ! -d "$fonts_dir" ]; then
    echo -e "${YELLOW}  fonts/ directory not found in repo${RESET}"
    return 1
  fi

  step_msg "Select a nerd font:"
  echo ""
  echo "    1) JetBrainsMono"
  echo "    2) FiraCode"
  echo ""
  read -rp "  Choice (1 or 2): " font_choice

  local font_file=""
  case "$font_choice" in
    1) font_file="JetBrainsMono.ttf" ;;
    2) font_file="FiraCode.ttf" ;;
    *)
      echo -e "${YELLOW}  Invalid choice — skipping${RESET}"
      return 1
      ;;
  esac

  local src="$fonts_dir/$font_file"
  if [ ! -f "$src" ]; then
    echo -e "${YELLOW}  Font file not found: $src${RESET}"
    return 1
  fi

  mkdir -p "$HOME/.termux"
  cp "$src" "$HOME/.termux/font.ttf"
  termux-reload-settings
  done_msg "Font set to $font_file"
}

# -----------------------------------------------
# Main
# -----------------------------------------------
main() {
  clear 2>/dev/null || true
  header

  # --- Status ---
  echo -e "${BOLD}Checking current system status...${RESET}"
  echo ""
  check_git
  check_mirror
  check_update
  check_packages
  check_ssh
  check_stow
  check_font
  echo ""

  # --- Menu ---
  show_menu
  read -r choices || choices=""

  # --- Build step list ---
  steps=()
  if [[ "$choices" == "8" ]] || [[ "$choices" == "all" ]]; then
    steps=(1 2 3 4 5 6 7)
  else
    for choice in $choices; do
      case "$choice" in
      1 | 2 | 3 | 4 | 5 | 6 | 7) add_step "$choice" ;;
      8 | all)
        steps=(1 2 3 4 5 6 7)
        break
        ;;
      *) echo -e "${YELLOW}Unknown step: $choice — ignoring${RESET}" ;;
      esac
    done
  fi

  if [ ${#steps[@]} -eq 0 ]; then
    echo -e "${YELLOW}No steps selected. Exiting.${RESET}"
    exit 0
  fi

  total_steps=${#steps[@]}
  echo ""

  # --- Execute ---
  for step in "${steps[@]}"; do
    case "$step" in
    1)
      step_num=$((step_num + 1))
      run_git
      ;;
    2)
      step_num=$((step_num + 1))
      run_mirror
      ;;
    3)
      step_num=$((step_num + 1))
      run_update
      ;;
    4)
      step_num=$((step_num + 1))
      run_packages
      ;;
    5)
      step_num=$((step_num + 1))
      run_ssh
      ;;
    6)
      step_num=$((step_num + 1))
      run_stow
      ;;
    7)
      step_num=$((step_num + 1))
      run_font
      ;;
    *) echo -e "${YELLOW}Unknown step: $step — skipping${RESET}" ;;
    esac
  done

  echo ""
  echo -e "${BOLD}=========================================${RESET}"
  echo -e "${GREEN}${BOLD}         Setup Complete!${RESET}"
  echo -e "${BOLD}=========================================${RESET}"
  echo ""
}

main "$@"
