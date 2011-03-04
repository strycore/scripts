# ~/.bashrc: executed by bash(1) for non-login shells.

[ -z "$PS1" ] && return

export HISTFILESIZE=100000000
export HISTSIZE=100000
export HISTIGNORE="cd:ls:[bf]g:clear:exit"
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
export EDITOR='vim'
export BROWSER='firefox'
export DEBEMAIL="strycore@gmail.com"
export DEBFULLNAME="Mathieu Comandon"

if [ -d /var/lib/gems/1.8/bin ] ; then
    export PATH=$PATH:/var/lib/gems/1.8/bin
fi

#minor errors in the spelling of a directory
#component in a cd command will be corrected.
shopt -s cdspell
#Bash attempts spelling correction on directory 
#names during word completion if the directory 
#name initially supplied does not exist. 
shopt -s dirspell
#the history list is appended to the file 
#named by the value of the HISTFILE variable 
#when the shell exits, rather than overwriting 
#the file.
shopt -s histappend
#Bash checks the window size after each command 
#and, if necessary, updates the values of LINES 
#and COLUMNS.
shopt -s checkwinsize

complete -cf sudo           #tab complete for sudo

set -o noclobber            # prevent overwriting files with cat

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    export PS1="(\[\e[0;37m\]\A\[\e[0;37m\]) \[\e[0;32m\]\u@\h\[\e[0;37m\]:\[\e[0;36m\]\w\[\e[0;37m\] \$ "

else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
alias ls='ls -hp --color'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias l='ls -lha'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias cd..='cd ..'
alias back='cd $OLDPWD'
alias df='df -h'
alias du='du -h -c'
alias hosts='$EDITOR /etc/hosts'
alias sfba="./symfony doctrine:build --all --and-load"
alias alert_helper='history|tail -n1|sed -e "s/^\s*[0-9]\+\s*//" -e "s/;\s*alert$//"'
alias alert='notify-send -i /usr/share/icons/gnome/32x32/apps/gnome-terminal.png "[0] "'

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
