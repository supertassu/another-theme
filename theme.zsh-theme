#!/usr/bin/env zsh

PROMPT='%B%F{red}%n%f%b %F{gray}in%f %F{cyan}%c%f %F{white}»%f '

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

autoload -U colors && colors

add-zsh-hook precmd prompt_precmd
add-zsh-hook preexec prompt_preexec

