# AGENTS.md — termux-setup

## What this repo is

Bash-based Termux setup automation + stow-managed dotfiles for Android. Single package, no build system, no tests.

## Architecture

```
.
├── setup.sh                    # Main entry point — interactive menu-driven setup
├── .bashrc                     # Shell config (stowed to ~)
├── .hushlogin                  # Suppresses Termux MOTD
├── .stow-local-ignore          # Excludes non-stowable items
├── .termux/termux.properties   # Extra keys layout + terminal settings
├── fonts/                      # Bundled Nerd Fonts (.ttf)
└── themes/                     # Bundled color themes (.properties)
```

## Key commands

```bash
bash setup.sh        # Run the setup script (from repo root)
stow .               # Symlink dotfiles to ~ (run from repo root)
stow -R .            # Restow after changes
termux-reload-settings  # Apply termux.properties / font / theme changes
```

## Setup script

- 9 options: git(1), mirror(2), update(3), packages(4), SSH(5), stow(6), font(7), theme(8), all(9)
- Idempotent — skips already-configured steps, safe to rerun
- `set -e` is on — avoid commands that return non-zero in status checks (use `|| true` or `$((step_num + 1))` instead of `((step_num++))`)
- Status check functions (`check_git`, `check_packages`, etc.) must NOT return non-zero — they only print status, they don't gate execution
- Package manager is `pkg` (Termux), not `apt`

## Stow conventions

- Repo root IS the stow package — run `stow .` from repo root, not from a subdirectory
- `.stow-local-ignore` excludes: `setup.sh`, `.git/`, `fonts/`, `themes/`
- After stowing, `termux-reload-settings` must run to apply changes
- Stow creates symlinks at `~/.bashrc` and `~/.termux/termux.properties`

## Shell (.bashrc) specifics

- Vi mode enabled (`set -o vi`) — arrow keys work in insert mode for history search
- `zoxide init bash` at bottom — must be last line
- Banner is bold cyan (`\033[1;36m`) — no truecolor or theme detection, terminal handles theme
- Prompt uses subshell `$(prompt_status)` for last-exit-status checkmark/cross
- Aliases use `eza` (not `ls`), `nvim` (not `vim`), `bat` (not `cat`)

## Gotchas

- `((step_num++))` returns exit code 1 when `step_num` is 0 under `set -e` — use `$((step_num + 1))` assignment instead
- `check_git` / `check_packages` / etc. are display-only — never let them `return 1` or the entire script dies
- Font and theme files are copied to `~/.termux/`, not stowed — they must live in `fonts/` and `themes/` dirs
- SSH key is Ed25519 at `~/.ssh/id_ed25519` — script skips if already exists
- `termux-change-repo` is an interactive TUI — script pauses with instructions before calling it
- `set -e` + interactive `read` can behave unexpectedly — always `read -r` and handle empty input

## File change rules

- **`setup.sh`**: Careful with `set -e` interactions; test that new steps don't break idempotency
- **`.bashrc`**: Keep `zoxide init bash` as last line; preserve vi mode; banner must stay bold cyan
- **`.termux/termux.properties`**: Test extra-keys syntax carefully — malformed JSON breaks the keyboard
- **`fonts/` and `themes/`**: New files must match the interactive menu case statements in `setup.sh`
- **`.stow-local-ignore`**: Any new non-stowable dirs/files must be added here
