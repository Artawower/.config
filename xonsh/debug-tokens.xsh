from pygments.token import Token
from xonsh.pyghooks import XonshLexer

def show_tokens(text):
    """Show all tokens for given text"""
    lexer = XonshLexer()
    tokens = list(lexer.get_tokens(text))
    for token, value in tokens:
        if value.strip():
            print(f'{str(token):40} "{value}"')

# Пример: show_tokens('ls ~/pwd')
