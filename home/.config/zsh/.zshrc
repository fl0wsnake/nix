function set_terminal_title() {
	echo -en "\e]2;$(sed s@^$HOME@~@<<<$PWD)" # it had \a at the end on the Internet where I found it
}
autoload -U add-zsh-hook && add-zsh-hook precmd set_terminal_title

# OPTIONS
setopt NOHISTEXPAND AUTOCD NO_HUP
setopt HIST_IGNORE_ALL_DUPS SHARE_HISTORY

alias a='file="$(~/.config/scripts/fuzzy-home)" && nnn "$file" && . "$NNN_TMPFILE"'
alias F='file="$(~/.config/scripts/fuzzy-ignored)" && nnn "$file" && . "$NNN_TMPFILE"'
alias f='file="$(~/.config/scripts/fuzzy)" && nnn "$file" && . "$NNN_TMPFILE"'

# Bookmarks
alias D="cd $RICE"

# 1 letter
alias c=calc
alias d=dict # TODO commented because expand-alias was trying to expand `nmcli d`
alias e="$EDITOR"
alias h="$EDITOR $HISTFILE"
alias j='journalctl --since today --reverse'
alias o=xdg-open
alias R='cd $(git rev-parse --show-toplevel)'
alias T="$HOME/.local/share/Trash/files"
alias x="$EXPLORER;. /tmp/.nnn.lastd"

# 2+ letters
alias bootfix='NIXOS_INSTALL_BOOTLOADER=1 /run/current-system/bin/switch-to-configuration boot'
alias clip="clipman pick --print0 --tool=CUSTOM --tool-args=\"fzf --prompt 'pick > ' --bind 'tab:up' --cycle --read0\""
alias cp='rsync -aP'
alias crawl='wget -r -l inf -k -p -N -e robots=off --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"'
alias di='nix-env -i'
alias drb="dr && reboot"
alias drs="dr && shutdown now"
alias dr="sudo nixos-rebuild switch && notify-send 'nixos-rebuild switch' || (notify-send 'failed'; exit 1)"
alias du='du -hs'
alias dun='nix-env --uninstall'
alias ewwd='killall -r eww; eww daemon; eww open bar; eww logs'
alias ga='git add -A'
alias gcl='git clone --recurse-submodules -j8'
alias gco='git checkout'
alias gc='(R && git commit -v)'
alias gd='(R && git diff --staged)'
alias gp='git push'
alias gs='(R && git status)'
alias kat='killall -15 -r'
alias md=mkdir
alias nowin='sudo efibootmgr -N'
alias PATH="echo $PATH | sed 's/:/\n/g' | fzf"
alias pg='pgrep -fa'
alias pkill='pkill -c'
alias pk='pkill -fc'
alias rsync-mtp='rsync -aP --no-perms --no-owner --no-group'
alias rsync='rsync -aP'
alias scl='systemctl --user'
alias sdn='shutdown now'
alias se="sudo -e"
alias tz='sudo timedatectl set-timezone "$(curl https://ipinfo.io/timezone)"'
alias win="sudo efibootmgr -n \$(sudo efibootmgr -v | grep -Po '(?<=Boot).*(?=\* Windows Boot Manager)')"
alias yt='yt-dlp -N 8 --downloader aria2c --yes-playlist'

. "$ZDOTDIR"/modules/keymaps
# . "$ZDOTDIR"/modules/expand-dots

# `^` for `ctrl`, `^[` for `alt`
bindkey "^[h" edit-history
bindkey "^[m" man-command
bindkey "^[c" yank-line
bindkey "^[s" toggle-sudo-prefix
bindkey "^[e" edit-command-line
bindkey '^[z' zshrc-edit
bindkey '^[x' explorer
bindkey ' ' expand-alias

# WIDGETS FOR BASH STANDARD BINDINGS
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
ds() {
  unbuffer nix-search -d "$@" | less
}
subs_set_default() { # set eng subs
  if [[ -z "$*" || -d "$*" ]]; then
    find "$@" -maxdepth 1 -name '*.mkv' -type f | while read -r file; do
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
mkvify() { Samsung Smart TV does not support .avi
  for file in "$@"; do 
    ($TERMINAL -e bash -c "ffmpeg -fflags +genpts -i '$file' -c:v copy -c:a copy -c:s srt '${file%.*}.mkv'") &
  done
}
mtp() { # go-mtpfs is the only one that works for android and still only on 2 attempt
  set +e
  fusermount -u "$@" 2>/dev/null; go-mtpfs "$@"&
  # pid=$!
  while read -r; do
    # kill $pid
    fusermount -u "$@" 2>/dev/null; go-mtpfs "$@"&
    # pid=$!
  done
}
probe() { # Samsung Smart TV does not support some audio codecs
  for i in "$@"; do
    echo "--> $i"
    ffprobe 2>&1 "$i" | grep -P '^ *Stream #'
  done
}

# eval "$(fzf --bash)" # for <C-r> history search
