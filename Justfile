default:
    just --choose

fedora-deps:
    if ! dnf repolist --all | rg -q '^terra\s'; then sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release; fi
    sudo dnf install \
    freetype-devel \
    libepoxy-devel \
    fontconfig-devel \
    cairo-devel \
    pango-devel \
    gtk4-devel \
    libadwaita-devel \
    libspiro-devel \
    android-tools \
    neohtop \
    fontconfig \
    pkg-config \
    rustup \
    openssl-devel \
    vulkan-loader-devel vulkan-headers shaderc
    
flatpak:
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo  
    flatpak install flathub io.github.seadve.Kooha
    flatpak install com.mattermost.Desktop
    flatpak install org.gnu.emacs
    flatpak install org.telegram.desktop
    flatpak install eu.betterbird.Betterbird
    flatpak install com.github.KRTirtho.Spotube

volta:
    volta install \
    node \
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
    npm-upgrade

cargo:
    PKG_CONFIG_PATH=/usr/lib64/pkgconfig
    LD_LIBRARY_PATH=/usr/lib64
    cargo install gitu kdlfmt
    cargo install wl-screenrec

uv:
    uv tool install rassumfrassum 
    uv tool install ty
    uv tool install basedpyright
    uv tool install httpie
    uv tool install http-prompt
  
    
[working-directory("./nix-linux")]
nix-linux:
    nix run home-manager/master -- switch --flake . --impure

[working-directory("/tmp")]
manual-deps:
    git clone https://github.com/leonardotrapani/hyprvoice.git
    cd hyprvoice
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
