#!/usr/bin/env zsh

prompt_set_title() {
    setopt localoptions noshwordsplit

    # emacs terminal does not support settings the title
    (( ${+EMACS} )) && return

    case $TTY in
        # Don't set title over serial console.
        /dev/ttyS[0-9]*) return;;
    esac

    local -a opts
    case $1 in
        expand-prompt) opts=(-P);;
        ignore-escape) opts=(-r);;
    esac

    # Set title atomically in one print statement so that it works
    # when XTRACE is enabled.
    print -n $opts $'\e]0;'${hostname}${2}$'\a'
}

prompt_precmd() {
  prompt_set_title 'expand-prompt' '%~'
}

prompt_preexec() {
  prompt_set_title 'ignore-escape' "$PWD:t: $2"
}

prompt_get_pwd() {
    git remote &> /dev/null
    if [ $? -eq 0 ]; then
        echo "%c"
    else
        echo "%~"
    fi
}

prompt_git_status() {
    git remote &> /dev/null

    if [ $? -eq 0 ]; then
        ref=$(git symbolic-ref HEAD | cut -d'/' -f3)
        echo " %F{yellow}$ref%f"
    fi

}

prompt_setup() {
    autoload -U colors && colors
    setopt PROMPT_SUBST

    add-zsh-hook precmd prompt_precmd
    add-zsh-hook preexec prompt_preexec

    PROMPT="%B%F{magenta}%n%f%b"
    [[ -v SSH_CLIENT ]] && PROMPT+="%F{magenta}@%m%f"
    
    PROMPT+=' %F{gray}in%f %F{cyan}$(prompt_get_pwd)%f$(prompt_git_status) %F{white}»%f '
}

prompt_setup
