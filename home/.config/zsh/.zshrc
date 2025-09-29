# OPTIONS
setopt AUTOCD NO_HUP
setopt HIST_IGNORE_ALL_DUPS SHARE_HISTORY

alias a='file="$(~/.config/scripts/fuzzy-home)" && nnn "$file" && . "$NNN_TMPFILE"'
alias F='file="$(~/.config/scripts/fuzzy-ignored)" && nnn "$file" && . "$NNN_TMPFILE"'
alias f='file="$(~/.config/scripts/fuzzy)" && nnn "$file" && . "$NNN_TMPFILE"'

# Bookmarks
alias D="cd $RICE"

# One letter
alias c=calc
alias d=dict
alias e="$EDITOR"
alias h="$EDITOR $HISTFILE"
alias o=xdg-open
alias x="$EXPLORER;. /tmp/.nnn.lastd"
alias R='cd $(git rev-parse --show-toplevel)'

# Multiple letters
alias yt='yt-dlp -N 8 --downloader aria2c --yes-playlist'
alias tz='sudo timedatectl set-timezone "$(curl https://ipinfo.io/timezone)"'
alias se="sudo -e"
alias scl='systemctl --user'
alias rsync='rsync -avhP'
alias rsync-mtp='rsync -avhP --no-perms --no-owner --no-group'
alias pkill='pkill -c'
alias md=mkdir
alias kat='killall -15 -r'
alias ka='killall -r'
alias jr='journalctl --since today --reverse'
alias gs='(R && git status)'
alias gp='git push'
alias gd='(R && git diff --staged)'
alias gc='(R && git commit -v)'
alias gcl='git clone --recurse-submodules -j8'
alias ga='git add -A'
alias ewwd='killall -r eww; eww daemon; eww open bar; eww logs'
alias dun='nix-env --uninstall'
alias ds="nix search nixpkgs"
alias dr="sudo nixos-rebuild switch && notify-send 'nixos-rebuild switch' || (notify-send 'failed'; exit 1)"
alias drs="dr && shutdown now"
alias drb="dr && reboot"
alias di='nix-env -i'
alias crawl='wget -r -l inf -k -p -N -e robots=off --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"'
alias clip="clipman pick --print0 --tool=CUSTOM --tool-args=\"fzf --prompt 'pick > ' --bind 'tab:up' --cycle --read0\""

. "$ZDOTDIR"/modules/keymaps

# `^` for `ctrl`, `^[` for `alt`
# KEYMAPS
bindkey "^[h" edit-history
bindkey "^[m" man-command
bindkey "^[c" yank-line
bindkey "^[s" toggle-sudo-prefix
bindkey "^[e" edit-command-line
bindkey '^[z' zshrc-edit
bindkey '^[x' explorer
bindkey ' ' expand-alias

# BASH STANDARD BINDINGS
bindkey '^[.' insert-last-word
bindkey '^n' down-history
bindkey '^p' up-history
bindkey '^[[Z' reverse-menu-complete # shift-tab
bindkey '^@' forward-word # ctrl-space
bindkey '^f' end-of-line
bindkey '^H' backward-kill-word # ctrl-backspace
bindkey '^[[3;5~' kill-word          # ctrl-del
bindkey '^[[1;5C' forward-word       # right
bindkey '^[[1;5D' backward-word      # left

# COMMANDS
subs_set_default() {
  if [[ -z "$*" || -d "$*" ]]; then
    find "$@" -name '*.mkv' -type f -maxdepth 1 | while read -r file; do
      echo "$file"
      subs_set_default_file "$file"
    done
  else
  subs_set_default_file "$@"
  fi
}
subs_set_default_file() {
  sub_count=0
  eng_sub_count=
  while read -r line; do
    if [[ $line =~ 'Track type: subtitles' ]]; then
      ((sub_count+=1))
    elif [[ $line =~ 'Language: eng' ]]; then
      eng_sub_count=$sub_count
    fi
  done < <(mkvinfo "$@")
  echo ${eng_sub_count:=$sub_count}
  mkvpropedit "$@" --edit track:s --set flag-default=0 >/dev/null 2>&1
  mkvpropedit "$@" --edit track:s"$eng_sub_count" --set flag-default=1
}
mkvify() {
  for file in "$@"; do 
    ($TERMINAL -e bash -c "ffmpeg -fflags +genpts -i '$file' -c:v copy -c:a copy -c:s srt '${file%.*}.mkv'") &
  done
}
mtp() {
  set +e
  fusermount -u "$@" 2>/dev/null; go-mtpfs "$@"&
  # pid=$!
  while read -r; do
    # kill $pid
    fusermount -u "$@" 2>/dev/null; go-mtpfs "$@"&
    # pid=$!
  done
}

# eval "$(fzf --bash)" # for <C-r> history search
