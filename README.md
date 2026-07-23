# termux-setup

One-command setup for a productive Termux environment on Android.

## What it does

Interactive setup script that configures Termux from a fresh install to a fully working dev environment:

- **Git identity** — sets name, email, and smart defaults
- **Package mirror** — selects fastest mirror for your region
- **System update** — updates all packages
- **Core packages** — neovim, tmux, eza, fzf, zoxide, bat, stow, and more
- **SSH key** — generates Ed25519 key pair
- **Dotfiles** — stows `.bashrc` and Termux config via GNU Stow
- **Nerd font** — JetBrainsMono or FiraCode (bundled)
- **Color theme** — 6 popular themes (Dracula, Catppuccin, Nord, Tokyo Night, Gruvbox, OneDark)

## Quick start

```bash
git clone https://github.com/adi/termux-setup.git ~/termux-setup
cd ~/termux-setup
bash setup.sh
```

Run the script, pick what you need (or hit `9` for all), and you're good to go.

## Repo structure

```
.
├── setup.sh              # Interactive setup script
├── .bashrc               # Shell config (stowed to ~)
├── .hushlogin            # Suppresses Termux welcome message
├── .termux/
│   └── termux.properties # Extra keys layout & terminal settings
├── fonts/
│   ├── JetBrainsMono.ttf
│   └── FiraCode.ttf
└── themes/
    ├── dracula.properties
    ├── catppuccin-mocha.properties
    ├── nord.properties
    ├── tokyo-night.properties
    ├── gruvbox-dark.properties
    └── onedark.properties
```

## Shell features

The `.bashrc` includes:

- **Startup banner** — cyan ASCII art on launch
- **Vi mode** — `set -o vi` with history search (arrow keys)
- **Smart aliases** — `ls`/`ll`/`la` via eza, `v` for nvim, `vz` for fzf+nvim
- **Zoxide** — `z` for smart directory jumping
- **Custom prompt** — checkmark/cross for last command status
- **Tmux shortcuts** — `t`, `ta`, `ts` for quick sessions

## Dotfile management

Uses [GNU Stow](https://www.gnu.org/software/stow/) to symlink config files. The repo is the stow package — run from the repo root:

```bash
stow .          # first time
stow -R .       # restow after changes
```

`termux-reload-settings` runs automatically after stowing.

## Setup steps

| # | Step | Description |
|---|------|-------------|
| 1 | Git | Configure `user.name` and `user.email` |
| 2 | Mirror | Select package mirror via `termux-change-repo` |
| 3 | Update | `pkg update && pkg upgrade` |
| 4 | Packages | Install 10 core packages |
| 5 | SSH | Generate Ed25519 key pair |
| 6 | Stow | Symlink dotfiles |
| 7 | Font | Choose JetBrainsMono or FiraCode |
| 8 | Theme | Pick a terminal color scheme |
| 9 | All | Run everything |
