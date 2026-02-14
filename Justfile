default:
    just --choose

fedora-deps:
    if [ ! -f /etc/yum.repos.d/terra.repo ]; then \
        sudo rpm -e terra-release 2>/dev/null || true; \
        sudo env -u LD_LIBRARY_PATH dnf install -y --nogpgcheck \
            --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release; \
    fi
    sudo dnf copr enable solopasha/hyprland
    sudo env -u LD_LIBRARY_PATH dnf clean all
    sudo env -u LD_LIBRARY_PATH dnf install -y --skip-unavailable \
        noctalia-shell \
        freetype-devel libepoxy-devel fontconfig-devel cairo-devel \
        pango-devel gtk4-devel libadwaita-devel libspiro-devel \
        android-tools neohtop fontconfig pkg-config rustup \
        openssl-devel vulkan-loader-devel vulkan-headers shaderc \
        docker docker-compose nodejs22 bun emacs hunspell \
        hunspell-ru hunspell-en-US wl-clipboard enchant2-devel \
        bitwarden swayidle rclone libevdev-devel \
        hyprland meson cmake cpio gcc-c++ gcc

    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER

    sudo rpm -v --import https://yum.tableplus.com/apt.tableplus.com.gpg.key
    sudo env -u LD_LIBRARY_PATH dnf config-manager addrepo --overwrite --from-repofile=https://yum.tableplus.com/rpm/arm64/tableplus.repo
    sudo env -u LD_LIBRARY_PATH dnf install -y tableplus

flatpak:
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub io.github.seadve.Kooha
    flatpak install -y flathub com.mattermost.Desktop
    flatpak install -y flathub org.telegram.desktop
    flatpak install -y flathub eu.betterbird.Betterbird
    flatpak install -y flathub com.github.KRTirtho.Spotube

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
    cargo install codebook-lsp

_cargo-linux:
    PKG_CONFIG_PATH=/usr/lib64/pkgconfig
    LD_LIBRARY_PATH=/usr/lib64
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
    @echo "Successfully applied Nix configuration for macOS."

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

hyprland-plugins:
    env -i HOME="$HOME" PATH="/usr/bin:/usr/sbin:/bin:/sbin" PKG_CONFIG_PATH="/usr/lib64/pkgconfig:/usr/share/pkgconfig" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" HYPRLAND_INSTANCE_SIGNATURE="$HYPRLAND_INSTANCE_SIGNATURE" hyprpm update -f
    env -i HOME="$HOME" PATH="/usr/bin:/usr/sbin:/bin:/sbin" PKG_CONFIG_PATH="/usr/lib64/pkgconfig:/usr/share/pkgconfig" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" HYPRLAND_INSTANCE_SIGNATURE="$HYPRLAND_INSTANCE_SIGNATURE" hyprpm add https://github.com/hyprwm/hyprland-plugins || true
    hyprpm enable hyprexpo || true
    hyprpm enable hyprfocus || true
    hyprpm reload

fedora-files:
    ln -s /home/darkawower/.config/vicinae/scripts /home/darkawower/.local/share/vicinae/scripts
    echo "darkawower ALL=(root) NOPASSWD: /home/darkawower/.local/bin/cpu-profile-apply" | sudo tee /etc/sudoers.d/cpu-profile
    sudo chmod 440 /etc/sudoers.d/cpu-profile

init-linux:
    just flatpak
    just fedora-deps
    just nix-linux
    just volta
    just uv
    just manual-deps
    just fedora-files
    just hyprland-plugins

init-mac:
    just volta
    just uv
