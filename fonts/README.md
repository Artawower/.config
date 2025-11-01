# Fonts Installation Guide

This directory contains only custom fonts that are not available in package managers.
Standard fonts should be installed via Homebrew or Nix for easier management.

## Custom Fonts (Included in Repository)

These fonts are kept in git as they're not available in Homebrew/Nix:

- **Ligamonacop** - Custom monospace font with ligatures
- **Ligamonacop Nerd Font** - Nerd Font patched version
- **Virgil** - Handwriting font (used by Excalidraw)

## Standard Fonts (Install via Package Manager)

### JetBrains Mono Nerd Font (Required for Emacs)

**Homebrew:**
```bash
brew install --cask font-jetbrains-mono-nerd-font
```

**Nix (in home-manager configuration):**
```nix
home.packages = with pkgs; [
  (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
];
```

### Fira Code

**Homebrew:**
```bash
brew install --cask font-fira-code
# Or with Nerd Font icons:
brew install --cask font-fira-code-nerd-font
```

**Nix:**
```nix
home.packages = with pkgs; [
  fira-code
  # Or with Nerd Font:
  (nerdfonts.override { fonts = [ "FiraCode" ]; })
];
```

### Cascadia Code

**Homebrew:**
```bash
brew install --cask font-cascadia-code
# Or Nerd Font version:
brew install --cask font-cascadia-code-nf
```

**Nix:**
```nix
home.packages = with pkgs; [
  cascadia-code
];
```

### GitHub Monaspace (Optional)

**Homebrew:**
```bash
brew install --cask font-monaspace
# Or Nerd Font version:
brew install --cask font-monaspace-nf
```

**Nix:**
```nix
home.packages = with pkgs; [
  monaspace
  # Or with Nerd Font:
  (nerdfonts.override { fonts = [ "Monaspace" ]; })
];
```

## Quick Install All (Homebrew)

```bash
brew install --cask \
  font-jetbrains-mono-nerd-font \
  font-fira-code \
  font-cascadia-code \
  font-monaspace-nf
```

## Quick Install All (Nix)

Add to your `home.nix`:

```nix
home.packages = with pkgs; [
  (nerdfonts.override { 
    fonts = [ "JetBrainsMono" "FiraCode" "Monaspace" ]; 
  })
  cascadia-code
];
```

## Using nix-darwin Configuration

If using `~/nix/darwin.nix`, fonts are already configured in the `homebrew.casks` section:

```nix
homebrew = {
  casks = [
    # Fonts - Development
    "font-jetbrains-mono-nerd-font"  # Main coding font with Nerd Font icons
    "font-fira-code"                  # Alternative with ligatures
    "font-cascadia-code"              # Microsoft's coding font
    "font-monaspace-nf"               # GitHub Monaspace with Nerd Font icons
    # ... other casks ...
  ];
};
```

After updating `darwin.nix`, run:
```bash
cd ~/nix
darwin-rebuild switch --flake .
```

## Why Not Keep Fonts in Git?

- **Size**: ~10MB of binary files
- **Updates**: Package managers keep fonts up-to-date automatically
- **Portability**: Same installation method across machines
- **Nerd Fonts**: Official Nerd Font patches ensure compatibility

Only custom/rare fonts that aren't in package managers are kept in this repository.
