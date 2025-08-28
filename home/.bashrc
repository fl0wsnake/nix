alias a='file="$(~/.config/scripts/fuzzy-home)" && nnn "$file" && . "$NNN_TMPFILE"'
alias F='file="$(~/.config/scripts/fuzzy-ignored)" && nnn "$file" && . "$NNN_TMPFILE"'
alias f='file="$(~/.config/scripts/fuzzy)" && nnn "$file" && . "$NNN_TMPFILE"'

alias c=calc
alias d=dict
alias e="$EDITOR"
alias h='$EDITOR $HISTFILE'
alias o=xdg-open
alias x="$EXPLORER"

alias ga='git add -A'
alias gs='git status'
alias gc='git status'
alias cp='rsync'
alias crawl='wget -r -l inf -k -p -N -e robots=off --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"'
alias di='nix-env -i'
alias dr="sudo nixos-rebuild switch && notify-send '*nixos-rebuild switch* done'"
alias ds="nix search nixpkgs"
alias du='nix-env --uninstall'
alias ewwd='killall -r eww; eww daemon; eww open bar; eww logs'
alias ka='killall -r'
alias md=mkdir
alias pkill='pkill -c'
alias rsync-mtp='rsync -vhaP --no-perms --no-owner --no-group'
alias rsync='rsync -vhaP'
alias se="sudo $EDITOR"
alias tz='sudo timedatectl set-timezone "$(curl https://ipinfo.io/timezone)"'
alias y='yt-dlp -N 8 --downloader aria2c --yes-playlist'

# eval "$(fzf --bash)" # for <C-r> history search

# CUSTOM COMMANDS
open-history() {
  $EDITOR "$HISTFILE"
}
bind -x '"\eh": open-history'

man-command() {
  line_first_word=$(awk '{print $1;}'<<<"$READLINE_LINE")
  if type -p "$line_first_word" &>/dev/null; then
    man "$line_first_word"
  fi
}
bind -x '"\em": man-command'

yank-line() {
  wl-copy -n<<<"$READLINE_LINE"
}
bind -x '"\ec": yank-line'

# OPTIONS
shopt -s autocd # make `..` like `cd ..` etc
shopt -s histappend

