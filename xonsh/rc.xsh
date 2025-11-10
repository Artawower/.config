import subprocess
from pathlib import Path

config_dir = Path.home() / '.config/xonsh'

source @(config_dir / 'env.xsh')
source @(config_dir / 'paths.xsh')
source @(config_dir / 'prompt.xsh')
source @(config_dir / 'hooks.xsh')
source @(config_dir / 'functions.xsh')
source @(config_dir / 'aliases.xsh')
source @(config_dir / 'completers.xsh')
