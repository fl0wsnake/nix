alias a='file="$(~/.config/scripts/fuzzy-home)" && nnn "$file" && . "$NNN_TMPFILE"'
alias F='file="$(~/.config/scripts/fuzzy-ignored)" && nnn "$file" && . "$NNN_TMPFILE"'
alias f='file="$(~/.config/scripts/fuzzy)" && nnn "$file" && . "$NNN_TMPFILE"'

alias c=calc
alias d=dict
alias e="$EDITOR"
alias h='$EDITOR $HISTFILE'
alias o=xdg-open
alias x="$EXPLORER"

alias cp='rsync'
alias crawl='wget -r -l inf -k -p -N -e robots=off --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"'
alias di='nix-env -i'
alias dr="sudo nixos-rebuild switch; notify-send '*nixos-rebuild switch* done'"
alias ds="nix search nixpkgs"
alias dun='nix-env --uninstall'
alias ewwd='killall -r eww; eww daemon; eww open bar; eww logs'
alias ga='git add -A'
alias gc='git status'
alias gs='git status'
alias jr='journalctl --since today --reverse'
alias ka='killall -r'
alias md=mkdir
alias pkill='pkill -c'
alias rsync-mtp='rsync -vhaP --no-perms --no-owner --no-group'
alias rsync='rsync -vhaP'
alias se="sudo $EDITOR"
alias tz='sudo timedatectl set-timezone "$(curl https://ipinfo.io/timezone)"'
alias yt='yt-dlp -N 8 --downloader aria2c --yes-playlist'

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

# OPTIONS
shopt -s autocd # make `..` like `cd ..` etc
shopt -s histappend

