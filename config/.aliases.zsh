
alias ls="eza --icons --long --header --color=always"
alias lss="ls --total-size --sort=size"
alias ll="ls"
alias l="ll"
alias la="l -A"

alias cd='z'
alias cat='bat'

alias nls="nslookup"

alias vi=nvim

alias vrc="vi ~/.zshrc"
alias src="source ~/.zshrc"

nohist() {
    unset HISTFILE
    HISTSIZE=0
    SAVEHIST=0
    setopt HIST_NO_STORE
    fc -p /dev/null 0 0
    print "zsh history is disabled for this session."
}

lg() {
    local tmpdir="${XDG_STATE_HOME:-$HOME/.local/state}/lazygit"
    mkdir -p "$tmpdir" || return

    export LAZYGIT_NEW_DIR_FILE
    LAZYGIT_NEW_DIR_FILE="$(mktemp "$tmpdir/newdir.XXXXXX")" || return

    lazygit "$@"

    if [ -s "$LAZYGIT_NEW_DIR_FILE" ]; then
        cd -- "$(cat "$LAZYGIT_NEW_DIR_FILE")"
    fi

    rm -f -- "$LAZYGIT_NEW_DIR_FILE"
    unset LAZYGIT_NEW_DIR_FILE
}

alias ld="lazydocker"

alias dc="docker compose"
alias venv="source .venv/bin/activate"

alias atsg='cd ~/Work/atsg/'
alias cart-api='cd ~/Work/cartanium-search-v3/projects/api/src/CartaniumSearch/'
alias cart='cd ~/Work/cartanium-search-v3/'
alias catalog='cd ~/Work/catalog_api/'
alias desk='cd ~/Desktop'
alias france='cd ~/Work/franses'
alias shared="cd ~/Work/ete-sync-heroku-docker/projects/ete-sync-heroku/etesyncshared/"
alias sync="cd ~/Work/ete-sync-heroku-docker/projects/ete-sync-heroku/"
alias telemetry='cd ~/Work/telemetry'
alias ui="cd ~/Work/ete-sync-heroku-docker/projects/buyete-sync-ui/"
alias work='cd ~/Work'
alias wa='cd ~/Work/writeaway'

alias atsg-load='tmuxp load atsg'
alias buyete-load='tmuxp load buyete'
alias writeaway-load='tmuxp load writeaway'
alias franses-load='tmuxp load franses'

alias tail-sync-stage="heroku logs --tail -a ete-sync-stage"
alias tail-buyete-stage="heroku logs --tail -a buyete-stage"
alias tail-buyete="heroku logs --tail -a buyete"

alias shell-sync-stage="heroku run bash -a ete-sync-stage"
alias shell-buyete-stage="heroku run bash -a buyete-stage"

alias pym-test="python manage.py test --keepdb"
alias pym-run="python manage.py runserver"
alias pym-run-catalog="python manage.py runserver 7011 --settings=catalogapi.settings"
alias pip-inst="pip install -r requirements.txt"
