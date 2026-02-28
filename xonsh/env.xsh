import os.path as op
import platform

_secrets = op.expanduser('~/.config/xonsh/.secrets.xsh')
if op.exists(_secrets):
    source @(_secrets)
del _secrets, op

$VI_MODE = 'INSIDE_EMACS' not in ${...}
$AUTO_CD = True
# $EDITOR = 'emacsclient -ac'
$EDITOR = 'hx'
$VISUAL = 'hx'
$JJ_EDITOR = 'hx'
# $VISUAL = 'emacsclient -ac'
if platform.system() == 'Linux':
  $EDITOR = 'hx'
  $VISUAL = 'hx'

$LSP_USE_PLISTS = 'true'
$PROMPT_FIELDS['env_name'] = ''
$XONSH_COLOR_STYLE = 'one-dark'
$DOTNET_CLI_TELEMETRY_OPTOUT = '1'
$DOTNET_ROOT = '/usr/local/share/dotnet'
$DOTNET_ROLL_FORWARD = "Major"
$GPG_TTY = $(tty).strip()

$XONSH_HISTORY_BACKEND = 'sqlite'

# Title терминала - показывает текущую задачу или директорию
$TITLE = '{current_job:{} | }{cwd}'

$XONSH_STYLE_OVERRIDES = {
    'Token.Name': 'ansired',                    
    'Token.Name.Builtin': 'ansibrightcyan',     
    'Token.Name.Constant': 'ansibrightblue',    
    'Token.Literal.String': 'ansibrightgreen'
}

$FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0"
