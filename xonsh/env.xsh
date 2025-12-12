import os.path as op
_secrets = op.expanduser('~/.config/xonsh/.secrets.xsh')
if op.exists(_secrets):
    source @(_secrets)
del _secrets, op

$VI_MODE = 'INSIDE_EMACS' not in ${...}
$AUTO_CD = True
$EDITOR = 'emacsclient -ac'
$VISUAL = 'emacsclient -ac'
$LSP_USE_PLISTS = 'true'
$PROMPT_FIELDS['env_name'] = ''
$XONSH_COLOR_STYLE = 'one-dark'
$DOTNET_CLI_TELEMETRY_OPTOUT = '1'
$DOTNET_ROOT = '/usr/local/share/dotnet'
$DOTNET_ROLL_FORWARD = "Major"

$XONSH_HISTORY_BACKEND = 'sqlite'

$XONSH_STYLE_OVERRIDES = {
    'Token.Name': 'ansired',                    
    'Token.Name.Builtin': 'ansibrightcyan',     
    'Token.Name.Constant': 'ansibrightblue',    
    'Token.Literal.String': 'ansibrightgreen'
}

