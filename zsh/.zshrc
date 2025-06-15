if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
  # exec tmux attach -t base || exec tmux new-session -s base
  exec tmux new-session
fi

bindkey -e

alias x="nnn";
alias nr="sudo nixos-rebuild switch";
alias e="nvim";
alias se="sudo nvim";
alias nix="nix --extra-experimental-features 'flakes nix-command'";

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line
