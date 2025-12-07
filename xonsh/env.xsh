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
$XONSH_COLOR_STYLE = 'monokai'
$DOTNET_CLI_TELEMETRY_OPTOUT = '1'
$DOTNET_ROOT = '/usr/local/share/dotnet'
$DOTNET_ROLL_FORWARD = "Major"

$XONSH_HISTORY_BACKEND = 'sqlite'

# Syntax highlighting overrides
$XONSH_STYLE_OVERRIDES = {
    'Token.Name': 'ansired',                    # Несуществующие команды - красным (для отладки)
    'Token.Name.Builtin': 'ansibrightcyan',     # Встроенные команды - ярко-голубым
    'Token.Name.Constant': 'ansibrightblue',    # Константы
    'Token.Literal.String': 'ansibrightgreen',  # Строки - ярко-зелёным
    'Token.Text': 'bold ansibrightblack',       # Аргументы - жирным серым
}

