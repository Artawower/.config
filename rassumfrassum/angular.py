"""Angular/TypeScript preset: typescript-language-server + eslint."""


def servers():
    return [
        ["ngserver", "--stdio", "--tsProbeLocations", ".", "--ngProbeLocations", "."],
        ['typescript-language-server', '--stdio'],
        ['codebook', 'serve'],
        # [
        #     "node",
        #     "~/.emacs.d/var/lsp/server/eslint/unzipped/extension/server/out/eslintServer.js",
        #     "--stdio",
        # ],
    ]
