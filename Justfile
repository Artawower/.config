default:
    just --choose

fedora-deps:
    sudo rm -f /etc/yum.repos.d/terra.repo
    if ! env -u LD_LIBRARY_PATH dnf repolist --all | rg -q '^terra\s'; then \
        sudo env -u LD_LIBRARY_PATH dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release; \
    fi

    sudo env -u LD_LIBRARY_PATH dnf install -y --skip-unavailable \
        freetype-devel libepoxy-devel fontconfig-devel cairo-devel \
        pango-devel gtk4-devel libadwaita-devel libspiro-devel \
        android-tools neohtop fontconfig pkg-config rustup \
        openssl-devel vulkan-loader-devel vulkan-headers shaderc \
        docker docker-compose nodejs22 bun emacs hunspell \
        hunspell-ru hunspell-en-US wl-clipboard enchant2-devel

    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER

    sudo rpm -v --import https://yum.tableplus.com/apt.tableplus.com.gpg.key
    sudo env -u LD_LIBRARY_PATH dnf config-manager addrepo --overwrite --from-repofile=https://yum.tableplus.com/rpm/arm64/tableplus.repo
    sudo env -u LD_LIBRARY_PATH dnf install -y tableplus
    
flatpak:
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo  
    flatpak install flathub io.github.seadve.Kooha
    flatpak install com.mattermost.Desktop
    flatpak install org.telegram.desktop
    flatpak install eu.betterbird.Betterbird
    flatpak install com.github.KRTirtho.Spotube

volta:
    volta install \
    node@22 \
    @angular/language-service@next \
    vscode-langservers-extracted \
    @angular/cli \
    copilot-node-server \
    yalc \
    lua-fmt \
    @anthropic-ai/claude-code \
    @openai/codex \
    @qwen-code/qwen-code@latest \
    mcp-codex-cli \
    @gy920/qwen-mcp-tool \
    pretty-ts-errors-markdown \
    playwright \
    typescript \
    typescript-language-server \
    @angular/language-server \
    @vue/language-server \
    @github/copilot-language-server \
    eslint \
    npm-check-updates \
    npm-upgrade \
    stylelint

cargo:
    just _cargo-{{os()}}

    cargo install gitu kdlfmt
    # Lsp checker for spelling
    cargo install codebook-lsp

_cargo-linux:
    PKG_CONFIG_PATH=/usr/lib64/pkgconfig
    LD_LIBRARY_PATH=/usr/lib64    # Lsp checker for spelling
    cargo install wl-screenrec

_cargo-macos:
    :
    
go:
    go install golang.org/x/tools/gopls@latest

uv:
    uv tool install rassumfrassum 
    uv tool install ty
    uv tool install basedpyright
    uv tool install httpie
    uv tool install http-prompt
  
    
[working-directory("./nix-linux")]
nix-linux:
    nix run home-manager/master -- switch --flake . --impure

nix-mac:
    just nix-home-mac
    just nix-darwin-mac

[working-directory("./nix")]
nix-darwin-mac:
    sudo -v && sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ~/.config/nix
    @echo "Sueccessfully applied Nix configuration for macOS."

[working-directory("./nix")]
nix-home-mac:
    nix run home-manager/master -- switch -b backup --flake ~/.config/nix
    @echo "Successfully applied Home Manager configuration for macOS."

[working-directory("./nix")]
nix-clean-mac:
	find "$$HOME" \
		-path "$$HOME/OrbStack/*" -prune -o \
		-path "$$HOME/Library/Containers/*" -prune -o \
		-xtype l -print0 | while IFS= read -r -d '' link; do \
			echo "Removing broken link: $$link"; \
			rm -f "$$link" 2>/dev/null || true; \
		done



[working-directory("/tmp")]
manual-deps:
    rm -rf /tmp/hyprvoice
    cd /tmp
    git clone https://github.com/leonardotrapani/hyprvoice.git
    cd /tmp/hyprvoice
    go mod download
    go build -o hyprvoice ./cmd/hyprvoice
    mkdir -p ~/.local/bin
    cp hyprvoice ~/.local/bin/

fedora-files:
    ln -s /home/darkawower/.config/vicinae/scripts /home/darkawower/.local/share/vicinae/scripts

init-linux:
    just flatpak
    just fedora-deps
    just nix-linux
    just volta
    just uv
    just manual-deps
    just fedora-files


init-mac:
    just volta
    just uv
    
