"""Python preset: pyright + ty"""

def servers():
    return [
        ['basedpyright-langserver', '--stdio'],
        ['ty', '--server'],
        ['codebook-lsp', 'serve'],
    ]
