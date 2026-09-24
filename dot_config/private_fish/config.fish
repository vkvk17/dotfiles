if status is-interactive
    set -gx EDITOR "emacsclient -nw"
    set -gx VISUAL $EDITOR

    fish_add_path $HOME/.cargo/bin

    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias ll='exa -alF'
    alias la='exa -A'
    alias cat='batcat --number'
    alias e="emacsclient -nw"
end