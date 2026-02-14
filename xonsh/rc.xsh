import subprocess
from pathlib import Path
from pprint import pprint

config_dir = Path.home() / '.config/xonsh'

source @(config_dir / 'env.xsh')
source @(config_dir / 'paths.xsh')
source @(config_dir / 'project-marker.xsh')
source @(config_dir / 'keybindings.xsh')
source @(config_dir / 'hooks.xsh')
source @(config_dir / 'functions.xsh')
source @(config_dir / 'aliases.xsh')
source @(config_dir / 'completers.xsh')
source @(config_dir / 'filters.xsh')
source @(config_dir / 'prompt.xsh')
source @(config_dir / 'zoxide.xsh')
source @(config_dir / 'autoenv.xsh')
source @(config_dir / 'smartenv.xsh')

source-bash ~/.nix-profile/etc/profile.d/hm-session-vars.sh

# Nix home-manager sets LD_LIBRARY_PATH with Nix libs, which breaks
# Fedora system binaries (e.g. libz version mismatch in binutils).
# Nix binaries don't need it — they use RPATH. Just unset it.
import platform as _platform
if _platform.system() == 'Linux':
    if 'LD_LIBRARY_PATH' in ${...}:
        del $LD_LIBRARY_PATH
del _platform
