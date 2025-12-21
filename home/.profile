### TRASH
export TRASH=~/.local/share/Trash/files

### HARDWARE
export CPU_COUNT=$((100 / $(getconf _NPROCESSORS_ONLN)))

### from .nix
# export XDG_RUNTIME_DIR="/run/user/$UID"
# export XDG_SESSION_TYPE='wayland' # Explicitly state the session type

### DEFAULT APPS
export SHELL_COMM=${SHELL##*\/} # $SHELL is defined by nixos
export EDITOR='nvim'
export VISUAL='nvim'
export MANPAGER='nvim +Man!'
export EXPLORER="nnn"
export TERMINAL='alacritty'
export BROWSER='app.zen_browser.zen'

### SYNC
export SYNC="$HOME/Dropbox"
. "$SYNC/.config/.profile"
export SCRIPTS_SYNC="${SYNC}/.config/scripts"
export WIKI="${SYNC}/Wiki"
export TODOS="${SYNC}/Todos"
export SCREENSHOTS="${SYNC}/Screenshots"

### DIRS
export RICE="$HOME/.config/nixos-rice"
export SCRIPTS="$HOME/.config/scripts" && export PATH="$SCRIPTS:$PATH"
export SCRIPTS_SWAY="$HOME/.config/sway/scripts"
export SYNC_MOBILE="$HOME/OneDrive"

### OPTS
export FZF_COLORS='hl:33,hl+:33' # for fzf.nvim
export FZF_DEFAULT_OPTS="--color ${FZF_COLORS} --ansi --history=/tmp/.fzf-history --bind=ctrl-d:page-down --bind=ctrl-u:page-up"
export GCM_CREDENTIAL_STORE='plaintext'
export GREP_COLORS='always'
export GRIM_DEFAULT_DIR="$SCREENSHOTS"
export GTK_THEME=Adwaita:dark # affects firefox, zen, gparted etc.
export NVIM_SESSION=$HOME/.local/state/nvim/session
export SXIV_SEL=/tmp/.nsxiv.sel
export VIMIV_TAGFILE=$HOME/.local/share/vimiv/tags/0

# GDK_SCALE="1.5"; # Gnome only supports non-fractional scaling by default. "2" is too much for 2560x1440 and "1" is too little.
# QT_SCALE_FACTOR="1.5";

### KITTY
export TMPDIR=/tmp

### ZSH
export ZDOTDIR=~/.config/zsh
export SAVEHIST=$HISTFILESIZE
# . $ZDOTDIR/param
# cp ~/.config/zsh-history /tmp/.zsh-history

### BASH
export PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"
export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTCONTROL=ignoredups:erasedups

### NNN
. "$HOME/.config/nnn/config"
