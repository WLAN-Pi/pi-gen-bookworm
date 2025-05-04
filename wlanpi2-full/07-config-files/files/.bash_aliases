# ~/.bash_alises

function make_safe_alias() {
    local alias_name="$1"
    local command_name="$2"
    local command_args="$3"

    alias "$alias_name"="command -v $command_name >/dev/null 2>&1 && $command_name $command_args || echo \"Error: $command_name is not installed\""
}

export EDITOR=vim
export VISUAL=vim

alias dir='dir --color=auto'
alias vdir='vdir --color=auto'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias ls='exa --grid --color auto --icons --sort=type'
alias ll='exa --long --color always --icons --sort=type'
alias la='exa --grid --all --color auto --icons --sort=type'
alias lt='exa --tree --level=2 --long --icons'

alias lless='less -RFX'

alias sudo='sudo '
alias temps='vcgencmd measure_temp && vcgencmd measure_volts'
alias journal='journalctl -f'
alias running='systemctl list-units --type=service --state=running'
alias boot='systemctl list-unit-files --state=enabled'
alias failed='systemctl --failed'
alias zombies='ps aux | grep Z'
alias kernellogs='journalctl -k --since "1 hour ago"'
alias secure-delete='shred -zvu -n 7'
alias mkdir='mkdir -pv'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias today='date +"%Y-%m-%d"'

alias ports='netstat -tulanp'
alias connections='netstat -nat | grep ESTABLISHED | wc -l'
alias dnsinfo='cat /etc/resolv.conf'
alias listening='sudo lsof -i -n | grep -E "LISTEN|ESTABLISHED"'
alias proctree='pstree -p'
alias openfiles='lsof | wc -l'
alias services='systemctl list-unit-files --type=service'

alias tmux-save='tmux capture-pane -pJ -S- > ~/tmux-output-$(date +%Y%m%d-%H%M%S).log'
make_safe_alias "gs" "git" "status"
make_safe_alias "ga" "git" "add"
make_safe_alias "gc" "git" "commit"
make_safe_alias "gl" "git" "log" "--oneline" "--graph"

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias vimrc='$EDITOR ~/.vimrc'
alias tmuxrc='$EDITOR ~/.tmux.conf'
alias bashrc='$EDITOR ~/.bashrc && echo "Reloading bash config..." && source ~/.bashrc'
alias aliasrc='$EDITOR ~/.bash_aliases && echo "Reloading aliases ..." && source ~/.bash_aliases'