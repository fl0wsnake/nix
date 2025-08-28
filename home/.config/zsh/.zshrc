### Ctrl-v or `cat -v` to see terminal escape sequences.

bindkey -e # for C-n, C-p, C-w bindings

### Title
precmd() {
  echo -en "\e]0;$(sed s@^$HOME@~@<<<$PWD)\a"
}
zshaddhistory() {
  echo -en "\e]0;$1\a"
}

mkvify() {
  for file in "$@"; do 
    ($TERMINAL -e bash -c "ffmpeg -fflags +genpts -i '$file' -c:v copy -c:a copy -c:s srt '${file%.*}.mkv'") &
  done
}

bindkey '^[h' zsh-history # TODO
bindkey '^[m' man-command # TODO
bindkey '^[c' yank-line # TODO
bindkey '^[z' zshrc-edit # TODO
# . "$MODULES"/zsh-autoquoter # TODO
bindkey '^[[3;5~' kill-word # Ctrl-Del
bindkey '^[[1;5C' forward-word # Right
bindkey '^[[1;5D' backward-word # Left

alias a='file=$(~/.config/scripts/fuzzy-home) && nnn $file && . $NNN_TMPFILE' # TODO remove separate script file
alias rsync-mtp='rsync -vhaP --no-perms --no-owner --no-group'
alias rsync='rsync -vhaP'
alias cp='rsync'
alias e="nvim"
alias F='file=$(~/.config/scripts/fuzzy-ignored) && nnn $file && . $NNN_TMPFILE' # TODO remove separate script file
alias f='file=$(~/.config/scripts/fuzzy) && nnn $file && . $NNN_TMPFILE' # TODO remove separate script file
alias nr="sudo nixos-rebuild switch"
alias ns="nix --extra-experimental-features 'flakes nix-command' search nixpkgs"
alias pkill='pkill -c'
alias se="sudo nvim"
alias x="nnn"

# # Enable Zsh's built-in completion system
# autoload -Uz compinit
# compinit

autoload -U edit-command-line && zle -N edit-command-line && bindkey '^[e' edit-command-line
