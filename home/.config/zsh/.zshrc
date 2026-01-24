. ~/.profile

function set_terminal_title() {
  echo -en "\e]2;$(sed s@^$HOME@~@<<<$PWD)" # it had \a at the end on the Internet where I found it
}
autoload -U add-zsh-hook && add-zsh-hook precmd set_terminal_title

# OPTIONS
setopt NOHISTEXPAND AUTOCD NO_HUP GLOB_DOTS
setopt HIST_IGNORE_ALL_DUPS SHARE_HISTORY

alias a='file="$(~/.config/scripts/fuzzy-home)" && nnn "$file" && . "$NNN_TMPFILE"'
alias F='file="$(~/.config/scripts/fuzzy-ignored)" && nnn "$file" && . "$NNN_TMPFILE"'
alias f='file="$(~/.config/scripts/fuzzy)" && nnn "$file" && . "$NNN_TMPFILE"'

# Bookmarks
alias D="cd $RICE"

alias bootfix='NIXOS_INSTALL_BOOTLOADER=1 /run/current-system/bin/switch-to-configuration boot'
alias ca=calc
alias clip="clipman pick --print0 --tool=CUSTOM --tool-args=\"fzf --prompt 'pick > ' --bind 'tab:up' --cycle --read0\""
alias cp='rsync -aP --info=progress2 --timeout=300'
alias crawl='wget -r -l inf -k -p -N -e robots=off --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"'
alias c=wl-copy
alias d=dict # TODO commented because expand-alias was trying to expand `nmcli d`
alias df='df -h'
alias diff='diff -r'
alias dl='nix profile list | grep'
alias drb="dr && reboot"
alias drs="dr && shutdown now"
alias dr="sudo nixos-rebuild switch && notify-send 'nixos-rebuild switch' || (notify-send 'failed'; exit 1)"
alias du='du -h'
alias dun='nix-env --uninstall'
alias dus='du -h * | sort -h'
alias e=nvim-smart
alias es='wl-paste | espeak --stdin'
alias ewwd='killall -r eww; eww daemon; eww open bar; eww logs'
alias fatcheck="find . -type d -print0 | xargs -0 -I D python3 -c \"import os,math; d='D'; s=sum(math.ceil(len(f)/13) for f in os.listdir(d) if os.path.isfile(os.path.join(d, f))); if s > 65536: print(d)\" 2>/dev/null" # FAT32 errors if ls_wc*filename_length/13>2^16
alias fdisk='sudo fdisk -l'
alias ga='git add -A'
alias gb='git branch'
alias gca='(R && git commit --amend --no-edit)'
alias gch='git checkout'
alias gcl='git clone --recurse-submodules -j8'
alias gc='(R && git commit -v)'
alias gd='(R && git diff)'
alias gds='(R && git diff --staged)'
alias gemini='gemini -r || gemini'
alias gl="git log --graph --oneline --decorate --all"
alias gparted='sudo -E gparted'
alias gp='git push'
alias gr="git reset"
alias gs='(R && git status)'
alias h="$EDITOR $HISTFILE"
alias j='jj'
alias jo='journalctl --since today --reverse'
alias kat='killall -15 -r'
alias ln='ln -sT'
alias lsblk='lsblk -f'
alias ls='ls --color=always -A'
alias md='mkdir -p'
alias mkdir='mkdir -p'
alias nix-shell="nix-shell --run zsh"
alias nowin='sudo efibootmgr -N'
alias o=xdg-open
alias PATH="echo $PATH | sed 's/:/\n/g' | fzf"
alias pg='pgrep -fal'
alias pkill='pkill -c'
alias pk='pkill -fc'
alias p=wl-paste
alias R='cd $(git rev-parse --show-toplevel)'
alias rsync-mtp='rsync -aP --no-perms --no-owner --no-group'
alias rsync='rsync -aP'
alias scl='systemctl --user'
alias sdn='shutdown now'
alias se="sudo -e"
alias T="$HOME/.local/share/Trash/files"
alias trash='trash -v'
alias t=/tmp
alias tz='sudo timedatectl set-timezone "$(curl https://ipinfo.io/timezone)"'
alias win="sudo efibootmgr -n \$(sudo efibootmgr -v | grep -Po '(?<=Boot).*(?=\* Windows Boot Manager)')"
alias x="$NNN_COMM"
alias xd='xdg-mime query default'
alias xq='xdg-mime query filetype'
alias yt='yt-dlp -N 8 --downloader aria2c --yes-playlist'

. "$ZDOTDIR"/modules/keymaps
. "$ZDOTDIR"/modules/expand-dots

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
di() {
  nix profile add nixpkgs/nixos-unstable#$@
}
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
timestampify() {
  while read line; do echo "$(date +%T): $line"; done
}

eval "$(fzf --zsh)" # for <C-r> history search
# eval "$(direnv hook zsh)"
