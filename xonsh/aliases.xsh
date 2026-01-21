aliases['c'] = 'clear'
aliases['с'] = 'clear'
aliases['..'] = 'cd ../'
aliases['b'] = 'cd -'
aliases['n'] = 'nvim'
aliases['y'] = 'yazi'
aliases['g'] = 'gitu'
aliases['п'] = 'gitu'

aliases['doom'] = '~/.emacs.d/bin/doom'
aliases['emacs30'] = '/opt/homebrew/Cellar/emacs-plus@30/30.0.93/bin/emacs --init-dir ~/.emacs.d-30'
aliases['pip'] = 'pip3'
aliases['python'] = 'python3'
# aliases['wakatime-cli'] = '/opt/homebrew/bin/wakatime'
aliases['nv'] = '~/.config/nv.sh'

aliases['ls'] = 'eza --icons'
aliases['tree'] = 'eza --tree'

aliases['br'] = 'bun run'
aliases['bi'] = 'bun install'
aliases['bis'] = 'bun install --exact --save'
aliases['bid'] = 'bun install --exact --save --dev'
aliases['pi'] = 'pnpm install'
aliases['pr'] = 'pnpm run'

aliases['m'] = 'minikube'
aliases['ms'] = 'minikube start --driver=docker --alsologtostderr'
aliases['md'] = 'minikube dashboard'
aliases['kg'] = 'kubectl get'

aliases['dublog'] = 'ssh darkawower@49.12.98.254'
aliases['on'] = 'ssh -i ~/.ssh/orgnote darkawower@65.108.90.95'

aliases['om'] = 'cd ~/projects/pet/orgnote'
aliases['oc'] = 'cd ~/projects/pet/orgnote/orgnote-client'
aliases['os'] = 'cd ~/projects/pet/orgnote/org-mode-ast'
aliases['oa'] = 'cd ~/projects/pet/orgnote/orgnote-api'
aliases['oci'] = 'cd ~/projects/pet/orgnote/orgnote-cli'
aliases['ob'] = 'cd ~/projects/pet/orgnote/orgnote-backend'
aliases['ui'] = 'cd ~/projects/ui/'
aliases['uim'] = 'cd ~/projects/ui-main-dev/'
aliases['ua'] = 'cd ~/projects/ui_alternative/'
aliases['mr'] = 'cd ~/projects/miron/'
aliases['pet'] = 'cd ~/projects/pet/'
aliases['sub'] = 'cd ~/projects/pet/subscrumber-repo/'

aliases['uclean'] = 'sudo nix-collect-garbage -d'

aliases['syncwp'] = 'unison -ui text "/Volumes/DARK SIDE/wallpappers/" ~/Pictures/wallpappers'
aliases['watch-dark-mode'] = 'sh ~/.config/scripts/kitty-auto-theme-switcher.sh &'
aliases['displays'] = '/Users/darkawower/.config/yabai/layouts/Arturs-MacBook-Pro.local/desktop.sh'
aliases['preserve-displays'] = '/Users/darkawower/.config/yabai/restore-script.sh'
aliases['volar'] = '/Users/darkawower/.npm-global/bin/vue-language-server'
aliases['dc'] = 'docker compose'
aliases['dcu'] = 'docker compose up'
aliases['d'] = 'docker'

aliases['ql'] = 'quasar clean'

aliases['o'] = 'opencode'

# Preserve PATH for sudo (needed for Nix commands)
aliases['sudo'] = 'sudo env PATH=$PATH'

# Yabai
aliases['yabai-apps'] = "yabai -m query --windows | jq '.[].app'"
aliases['yabai-titles'] = "yabai -m query --windows | jq '.[].title'"
aliases['j'] = 'just ~/.config/'
