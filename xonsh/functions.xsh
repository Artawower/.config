from pathlib import Path
from xonsh import color_tools

def _e(args):
    ![emacsclient -ac @(args)]

def _cl(args):
    ![claude -p @(args)]

def _zi(args):
    $ANTHROPIC_BASE_URL = 'https://api.z.ai/api/anthropic'
    $ANTHROPIC_AUTH_TOKEN = '30781b3da8e6457e9006abd32b386b5e.BGq0klizgyLUoNuN'
    ![claude @(args)]

def _gp(args):
    ![gemini -p @(args)]

def _vis(args):
    ![volta install @(args)]

def _wk(args):
    ![wakafetch -f --days 1 @(args)]

def _docker_clean(args):
    ![docker image prune -a]
    ![docker system prune -a --volumes]

def _bu(args):
    ![brew update]
    ![brew outdated]

def _ghll(args):
    run_id = $(gh run list --limit 1 --json databaseId --jq '.[0].databaseId').strip()
    ![gh run view @(run_id) --log | cat @(args)]

def _on(args):
    ![ssh -i ~/.ssh/orgnote darkawower@65.108.90.95 @(args)]

def _dublog(args):
    ![ssh -i ~/.ssh/dublog darkawower@49.12.98.254 @(args)]

def _farm(args):
    ![ssh -i ~/.ssh/farm artur@chiafarm.hopto.org -p 2222 @(args)]

def _farmd(args):
    ![ssh -i ~/.ssh/farm artur@chiafarm.freeddns.org -p 2222 @(args)]

def _remote_vpn(args):
    ![ssh -i ~/.ssh/wgvpn darkawower@146.59.44.175 @(args)]

def _remote_amnezia(args):
    ![ssh -i ~/.ssh/wgvpn debian@146.59.44.175 @(args)]

def _reload(args):
    config_path = Path.home() / '.config/xonsh' / 'rc.xsh'
    if config_path.exists():
        execx(open(config_path).read(), 'exec', __xonsh__.ctx, filename=str(config_path))
        print('Config reloaded')
    else:
        print(f'Config not found: {config_path}')

def _u(args): 
    cd ~/nix
    ![make rebuild]

def _uh(args): 
    cd ~/nix
    ![make home]

def _ud(args): 
    cd ~/nix
    ![make darwin]

def print_colors():
    for name, (r, g, b) in color_tools.BASE_XONSH_COLORS.items():
        print(f"\033[48;2;{r};{g};{b}m  \033[0m {name:20} rgb({r},{g},{b})")

aliases['e'] = _e
aliases['cl'] = _cl
aliases['zi'] = _zi
aliases['gp'] = _gp
aliases['vis'] = _vis
aliases['wk'] = _wk
aliases['docker-clean'] = _docker_clean
aliases['bu'] = _bu
aliases['ghll'] = _ghll
aliases['on'] = _on
aliases['dublog'] = _dublog
aliases['farm'] = _farm
aliases['farmd'] = _farmd
aliases['remote-vpn'] = _remote_vpn
aliases['remote-amnezia'] = _remote_amnezia
aliases['reload'] = _reload
aliases['u'] = _u
aliases['uh'] = _uh
aliases['ud'] = _ud
