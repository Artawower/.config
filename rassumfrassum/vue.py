"""Vue/TypeScript preset: typescript-language-server + eslint."""

def servers():
    return [
        ['typescript-language-server', '--stdio'],
        # ["node", "/Users/darkawower/.emacs.d/var/lsp/server/eslint/unzipped/extension/server/out/eslintServer.js", '--stdio']
    ]
