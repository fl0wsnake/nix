### MTPFS
export MTPFS='/run/media/$USER/|mtp'
sudo mkdir -p "$MTPFS"
sudo chown $USER $MTPFS

### Trash
trash-empty 28 -f
export TRASH=~/.local/share/Trash/files

### from .nix
export XDG_RUNTIME_DIR="/run/user/$UID"
export XDG_SESSION_TYPE='wayland' # Explicitly state the session type
export PATH="$PATH:$HOME/.config/scripts:$HOME/.local/bin"
export NIX_BUILD_CORES=0 # works at least for `nix-collect-garbage`

### Default apps
export SHELL_COMM=${SHELL##*\/} # $SHELL is defined by nixos
export EDITOR="nvim"
export VISUAL="nvim"
export MANPAGER='nvim +Man!'
export EXPLORER="nnn"
export TERMINAL="alacritty"
export BROWSER="flatpak run app.zen_browser.zen"
export HYPR_BORDER_SIZE=2 # for hacking hypr's window cycling

### Sync
export SYNC="$HOME/Dropbox"
. "$SYNC/.config/.profile"
export SCRIPTS_SYNC="${SYNC}/.config/scripts"
export WIKI="${SYNC}/Wiki"
export TODOS="${SYNC}/Todos"
export SCREENSHOTS="${SYNC}/Screenshots"

### Dirs
export SCRIPTS="$HOME/.config/scripts"
# export HYPR_SCRIPTS="$HOME/.config/scripts"
export SWAY_SCRIPTS="$HOME/.config/sway/scripts"
export SYNC_MOBILE="$HOME/OneDrive"
export RICE="$HOME/.config/nixos-rice"

### Opts
export GTK_THEME=Adwaita:dark # make Firefox-like apps dark themed (like Zen)
export GRIM_DEFAULT_DIR="$SCREENSHOTS"
export GREP_COLORS='always'
export FZF_COLORS='hl:33,hl+:33' # for fzf.nvim
export FZF_DEFAULT_OPTS="--color ${FZF_COLORS} --ansi --history=/tmp/.fzf-history --bind=ctrl-d:page-down --bind=ctrl-u:page-up"
export GCM_CREDENTIAL_STORE='plaintext'

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

### nnn
. "$HOME/.config/nnn/config"
