FZF_BIN="$(which fzf)"
SED_BIN="$(which sed)"

typeset -ga JUMP_ALIAS_FILES
(( ${#JUMP_ALIAS_FILES[@]} )) || JUMP_ALIAS_FILES=("$HOME/.aliases.zsh")

typeset -ga TMUXP_ALIAS_FILES
(( ${#TMUXP_ALIAS_FILES[@]} )) || TMUXP_ALIAS_FILES=("$HOME/.aliases.zsh")

get_jump_aliases() {
  local name target_path

  $SED_BIN -nE "s/^alias ([^=]+)=['\"]cd (.*)['\"]$/\1|\2/p" "${JUMP_ALIAS_FILES[@]}" 2>/dev/null |
  while IFS="|" read -r name target_path; do
    target_path="${target_path/#\~/$HOME}"
    printf "%s|%s\n" "$name" "$target_path"
  done
}

get_tmuxp_aliases() {
  local name tmuxp_command

  $SED_BIN -nE "s/^alias ([^=]+)=['\"](tmuxp load .*)['\"]$/\1|\2/p" "${TMUXP_ALIAS_FILES[@]}" 2>/dev/null |
  while IFS="|" read -r name tmuxp_command; do
    printf "%s|%s\n" "$name" "$tmuxp_command"
  done
}

icon_for() {
  case "$1" in
    work) echo "💼" ;;
    france|franses) echo "🇫🇷" ;;
    cart*) echo "🛒" ;;
    catalog) echo "📦" ;;
    sync|shared) echo "🔄" ;;
    ui) echo "🖥️" ;;
    telemetry) echo "📊" ;;
    *) echo "📁" ;;
  esac
}
      # --preview 'echo {} | awk "{print \$NF}" | xargs -I {} ls -la {}' \

jump() {
  local line key target_path

  line=$(get_jump_aliases | while IFS="|" read -r name target_path; do
    printf "%s  %-12s %s\n" "$(icon_for "$name")" "$name" "$target_path"
  done | fzf \
      --prompt="Jump ❯ " \
      --ansi \
      --preview 'dir=$(echo {} | awk "{print \$NF}"); ls -la "$dir"; git -C "$dir" status 2>/dev/null' \
      --preview-window=right:60%)

  [[ -z "$line" ]] && return

  key=$(echo "$line" | awk '{print $2}')
  target_path=$(get_jump_aliases | grep "^$key|" | cut -d'|' -f2)

  cd "$target_path"
}

tmuxp_project() {
  local line key tmuxp_command
  local -a tmuxp_args

  line=$(get_tmuxp_aliases | while IFS="|" read -r name tmuxp_command; do
    printf "%s  %-16s %s\n" "$(icon_for "$name")" "$name" "$tmuxp_command"
  done | fzf \
      --prompt="Tmuxp ❯ " \
      --ansi)

  [[ -z "$line" ]] && return

  key=$(echo "$line" | awk '{print $2}')
  tmuxp_command=$(get_tmuxp_aliases | awk -F'|' -v key="$key" '$1 == key {print $2; exit}')
  [[ -z "$tmuxp_command" ]] && return 1

  tmuxp_args=("${(z)tmuxp_command}")
  "${tmuxp_args[@]}"
}

function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
    zle reset-prompt > /dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}

bindkey -s '^G' 'jump\n'
bindkey -s '^X^P' 'tmuxp_project\n'
zle     -N             sesh-sessions
bindkey -M emacs '\es' sesh-sessions
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions
