# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#


# ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"
# ZSH_THEME="spaceship"


# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
	zsh-autosuggestions
	sudo
	kubectl
	# zsh-autocomplete
	zsh-wakatime
	macos
	zsh-vi-mode
	web-search
  zsh-kubectl-prompt
  helm
	# history-substring-search
	#   zsh-completions
)

source $ZSH/oh-my-zsh.sh

RPROMPT='%{$fg[blue]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}'

# Autosuggestions
# ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# 
# # Fix zsh autosuggestions keybind for arrow keys
# bindkey '\e[A' history-beginning-search-backward
# bindkey '\e[B' history-beginning-search-forward
#
# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
export EDITOR='nvim'
export VISUAL='nvim'


# Aliases
alias doom="~/.emacs.d/bin/doom"
alias pip="pip3"
alias python="python3"
alias wakatime-cli="/opt/homebrew/bin/wakatime"
alias nv="~/.config/nv.sh"
alias ssh="kitty +kitten ssh"
alias ls="exa --icons"
alias syncwp="unison -ui text /Volumes/DARK\ SIDE/wallpappers/ ~/Pictures/wallpappers"
alias m="minikube"
alias ms="minikube start --driver=docker --alsologtostderr"
alias md="m dashboard"
alias n="nvim"
alias kg="kubectl get"
alias c="clear"
alias dublog="ssh darkawower@217.25.89.126"
alias farm="ssh -i ~/.ssh/farm artur@chiafarm.hopto.org -p 2222"
alias b="cd ~/projects/pet/second-brain"
alias bc="cd ~/projects/pet/second-brain/second-brain-client"
alias bp="cd ~/projects/pet/second-brain/second-brain-publisher"
alias br="cd ~/projects/pet/second-brain/second-brain-parser"

function searchBitwarden () {
  bw list items --search "$1" | jq '.[] | "[" + .name + "]: " + .login.username + " - " + .login.password + "    (" + .id + ")"'
}

alias bws="searchBitwarden"

function createBitwardenLogin () {
  local password=$3
  echo $password
  bw get template item | jq ".name=\"$1\" | .login=$(bw get template item.login | jq ".username=\"$2\" | .password=\"$password\"")" | bw encode | bw create item | jq -C
  # bw get template item | jq --arg USERNAME "$2" --arg PASSWORD "$password" ".name=\"$1\" | .login=$(bw get template item.login | jq '.username="$USERNAME" | .password="$PASSWORD"')" | bw encode | bw create item
}

alias bwc="createBitwardenLogin"
# Easy connections
alias sk8s="ssh darkawower@116.203.183.233"
alias ssn="ssh darkawower@94.130.231.115"
alias pi="ssh pi@raspberrypi"
alias sb="ssh darkawower@65.108.90.95"
alias pir="ssh -D 600 pi@socializer.hopto.org"
alias sspice="ssh -i /Users/darkawower/.ssh/spice root@195.201.131.141"
# alias drone="ssh ubuntu@129.151.217.221"
alias drone="ssh darkawower@89.223.71.16"

# Most popular DIR navigation
alias ui="cd ~/projects/ui/"
alias mr="cd ~/projects/miron/"
alias pet="cd ~/projects/pet/"


# Paths
export PATH=$PATH:/opt/homebrew/bin
export ZSH_WAKATIME_BIN=/opt/homebrew/bin/wakatime
export PATH="${PATH}:${HOME}/.local/bin/"

export PATH="$PATH:"/usr/local/opt/bin/
export PATH="$PATH:"/usr/local/bin/
export PATH="$PATH:"/usr/bin/
export PATH="$PATH:"/Users/darkawower/dev/flutter/bin
export PATH="$PATH:${HOME}/tmp/lua-language-server/bin"

# Golang
export GOPATH="${HOME}/.go"
export GOROOT="$(brew --prefix golang)/libexec"
export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"

test -d "${GOPATH}" || mkdir "${GOPATH}"
test -d "${GOPATH}/src/github.com" || mkdir -p "${GOPATH}/src/github.com"



# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


function my_init() {
  # bindkey "^K" history-substring-search-up
  # bindkey "^J" history-substring-search-down
  # bindkey '^L' autosuggest-accept-suggested-small-word
  bindkey '^L' end-of-line


  bindkey "^K" history-beginning-search-backward
  bindkey "^F" history-beginning-search-forward
  
  # bindkey "^[[5~" history-beginning-search-backward
  # bindkey "^[[6~" history-beginning-search-forward
  bindkey "^[[A" history-beginning-search-backward
  bindkey "^[[B" history-beginning-search-forward
}
zvm_after_init_commands+=(my_init)


eval "$(bw completion --shell zsh); compdef _bw bw;"
alias luamake=/Users/darkawower/tmp/lua-language-server/3rd/luamake/luamake

export PATH="/usr/local/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/darkawower/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end
#
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

export WORKON_HOME=~/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/Users/darkawower/.pyenv/shims/python
# export PATH="/opt/homebrew/opt/node@14/bin:$PATH"
# export PATH="/opt/homebrew/opt/node@16/bin:$PATH"
# export PATH="/opt/homebrew/opt/node@14/bin:$PATH"
export PATH="/opt/homebrew/lib/node_modules/typescript/bin:$PATH"
export PATH="/opt/homebrew/opt/node@16/bin:$PATH"
export PATH=~/.npm-global/bin:$PATH
# export PATH="/opt/homebrew/opt/node@14/bin:$PATH"
# Max files for emacs bootload 
# sudo launchctl limit maxfiles 65536 200000
# export LSP_USE_PLISTS=true

