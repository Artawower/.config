default:
    just --choose

fedora-deps:
    sudo dnf install \
    freetype-devel \
    libepoxy-devel \
    fontconfig-devel \
    cairo-devel \
    pango-devel \
    gtk4-devel \
    libadwaita-devel \
    libspiro-devel \
    
flatpak:
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo  
    flatpak install flathub io.github.seadve.Kooha
    flatpak install com.mattermost.Desktop
    flatpak install org.gnu.emacs
    flatpak install org.telegram.desktop
    flatpak install eu.betterbird.Betterbird

volta:
    volta install \
    node \
    @angular/language-service@next \
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
    @angular/language-server \
    @vue/language-server

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

init-linux:
    just flatpak
    just fedora-deps
    just nix-linux
    just volta
    just uv
    just manual-deps
