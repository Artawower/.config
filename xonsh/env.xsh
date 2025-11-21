$VI_MODE = True
$AUTO_CD = True
$EDITOR = 'emacsclient -ac'
$VISUAL = 'emacsclient -ac'
$LSP_USE_PLISTS = 'true'
$PROMPT_FIELDS['env_name'] = ''
$XONSH_COLOR_STYLE = 'monokai'

$XONSH_HISTORY_BACKEND = 'sqlite'

# Syntax highlighting overrides
$XONSH_STYLE_OVERRIDES = {
    'Token.Name': 'ansired',                    # Несуществующие команды - красным (для отладки)
    'Token.Name.Builtin': 'ansibrightcyan',     # Встроенные команды - ярко-голубым
    'Token.Name.Constant': 'ansibrightblue',    # Константы
    'Token.Literal.String': 'ansibrightgreen',  # Строки - ярко-зелёным
    'Token.Text': 'bold ansibrightblack',       # Аргументы - жирным серым
}

