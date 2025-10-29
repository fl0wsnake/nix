alias a='file="$(~/.config/scripts/fuzzy-home)" && nnn "$file" && . "$NNN_TMPFILE"'
alias F='file="$(~/.config/scripts/fuzzy-ignored)" && nnn "$file" && . "$NNN_TMPFILE"'
alias f='file="$(~/.config/scripts/fuzzy)" && nnn "$file" && . "$NNN_TMPFILE"'

# Bookmarks
alias D="cd $RICE"

# One letter
alias c=calc
alias d=dict
alias e="$EDITOR"
alias h='$EDITOR $HISTFILE'
alias o=xdg-open
alias x="$EXPLORER"

# Multiple letters
alias yt='yt-dlp -N 8 --downloader aria2c --yes-playlist'
alias win="sudo efibootmgr -n \$(sudo efibootmgr -v | grep -Po '(?<=Boot).*(?=\* Windows Boot Manager)')"
alias tz='sudo timedatectl set-timezone "$(curl https://ipinfo.io/timezone)"'
alias se="sudo -e"
alias scl='systemctl --user'
alias rsync='rsync -aP'
alias rsync-mtp='rsync -aP --no-perms --no-owner --no-group'
alias pk='pkill -fc'
alias pkill='pkill -c'
alias pg='pgrep -fa'
alias PATH="echo $PATH | sed 's/:/\n/g' | fzf"
alias nowin='sudo efibootmgr -N'
alias md=mkdir
alias kat='killall -15 -r'
alias gs='(R && git status)'
alias gp='git push'
alias gd='(R && git diff --staged)'
alias gc='(R && git commit -v)'
alias gco='git checkout'
alias gcl='git clone --recurse-submodules -j8'
alias ga='git add -A'
alias ewwd='killall -r eww; eww daemon; eww open bar; eww logs'
alias dun='nix-env --uninstall'
alias du='du -hs'
alias ds="nix-search -d"
alias dr="sudo nixos-rebuild switch && notify-send 'nixos-rebuild switch' || (notify-send 'failed'; exit 1)"
alias drs="dr && shutdown now"
alias drb="dr && reboot"
alias di='nix-env -i'
alias crawl='wget -r -l inf -k -p -N -e robots=off --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"'
alias cp='rsync -aP'
alias clip="clipman pick --print0 --tool=CUSTOM --tool-args=\"fzf --prompt 'pick > ' --bind 'tab:up' --cycle --read0\""
alias bootfix='NIXOS_INSTALL_BOOTLOADER=1 /run/current-system/bin/switch-to-configuration boot'

# eval "$(fzf --bash)" # for <C-r> history search

# CUSTOM COMMANDS
# \e for alt, \C- for ctrl
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


toggle_sudo_prefix() {
  READLINE_LINE_ARRAY=($(echo $READLINE_LINE))
  if [[ ${READLINE_LINE_ARRAY[0]} == 'sudo' ]]; then
    READLINE_LINE=$(echo "$READLINE_LINE" | sed -E 's/^\s*sudo\s*//')
  else
    READLINE_LINE="sudo $READLINE_LINE"
  fi
}
bind -x '"\es": toggle_sudo_prefix'

edit_command_line() {
  local tmp_file=$(mktemp)
  echo "$READLINE_LINE" > "$tmp_file"
  $EDITOR +'se ft=sh' "$tmp_file"
  READLINE_LINE="$(<"$tmp_file")"
  READLINE_POINT="${#READLINE_LINE}"
  rm "$tmp_file"
}
bind -x '"\M-e":edit_command_line'

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

# OPTIONS
shopt -s autocd # make `..` like `cd ..` etc
shopt -s histappend
