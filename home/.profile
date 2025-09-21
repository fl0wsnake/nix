### MTPFS
export MTPFS=/run/media/$USER/mtp
sudo mkdir -p "$MTPFS"
sudo chown $USER $MTPFS

### Trash
trash-empty 28 -f
export TRASH=~/.local/share/Trash/files

### from .nix
export XDG_RUNTIME_DIR="/run/user/$UID"
export XDG_SESSION_TYPE='wayland' # Explicitly state the session type
export PATH="$PATH:$HOME/.config/scripts"

### Default apps
export SHELL_COMM="$(grep -Po '[^\/]+$'<<<"$SHELL")" # $SHELL is defined by nixos
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

### BASH
export PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"
export HISTSIZE=1000
export HISTFILESIZE=2000
export HISTCONTROL=ignoredups:erasedups

### [nnn](https://github.com/jarun/nnn)
export NNN_TMPFILE=/tmp/.nnn.lastd
export NNN_SCOPE=1
export NNN_USE_EDITOR=1
export NNN_TRASH=1
export NNN_OPTS='HRAJxE'
export NNN_ORDER="t:$HOME/Downloads;t:/tmp;t:$SCREENSHOTS;t:/var/log"
export NNN_FIFO=/tmp/.nnn.fifo
export NNN_SEL='/tmp/.nnn.sel'
export NNN_PLUG;NNN_PLUG=$(tr -d '\n' <<<"
m:mtpmount;
d:diffs;
p:preview-tabbed;
P:preview-tui;
r:rsynccp;
R:renamer;
v:-!vimiv --command 'toggle thumbnail' *;
>:-!mogrify -rotate 90 '\$PWD/\$nnn'*;
<:-!mogrify -rotate -90 '\$PWD/\$nnn'*;
s:-!echo -n>$NNN_SEL*;
n:-!nautilus . &*;
y:-!wl-copy \$(sed s@^$HOME@~@ <<<\"\$PWD/\$nnn\")*;
Y:-!wl-copy \$(sed s@^$HOME@~@ <<<\"\$PWD\")*;
P:!printf '%s' '0c\$(dirname \"\$(wl-paste)\")' >\$NNN_PIPE*;
a:!file=\$($SCRIPTS/fuzzy-home) && echo -n \"0c\$file\" >\$NNN_PIPE*;
f:!file=\$($SCRIPTS/fuzzy) && echo -n \"0c\$file\" >\$NNN_PIPE*;
F:!file=\$($SCRIPTS/fuzzy-ignored) && echo -n \"0c\$file\" >\$NNN_PIPE*;
")
export NNN_BMS;NNN_BMS=$(tr -d '\n' <<<"
d:$HOME/Downloads;
m:/run/media/$USER;
M:/run/user/$UID/gvfs;
o:$TODOS;
s:$SYNC;
S:$SCREENSHOTS;
t:/tmp;
T:$TRASH;
w:$HOME/WS;
")
