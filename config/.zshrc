# Starship
eval "$(starship init zsh)"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Rust
export PATH="$(brew --prefix rustup)/bin:$PATH"

# Zoxide
eval "$(zoxide init zsh)"

# Ngrok
if command -v ngrok &>/dev/null; then
    eval "$(ngrok completion)"
fi

# Tmux
export DISABLE_AUTO_TITLE='true'

# Bitwarden
export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/colino/.lmstudio/bin"
# End of LM Studio CLI section

# Android dev
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export PATH="$JAVA_HOME/bin:$PATH"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

# bun
[ -s "/Users/colino/.bun/_bun" ] && source "/Users/colino/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# My stuff :)
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.bin:$PATH"

# Change directories without 'cd'
setopt AUTO_CD

# Case-insensitive completion
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Use default emacs bindings
bindkey -e

source ~/.aliases.zsh
source ~/.zsh_jumps.zsh

# Edit command line in editor.
export EDITOR=hx
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
