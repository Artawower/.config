"""Angular/TypeScript preset: typescript-language-server + eslint."""


def servers():
    return [
        ['typescript-language-server', '--stdio'],
        ["ngserver", "--stdio", "--tsProbeLocations", ".", "--ngProbeLocations", "."],
        ['codebook-lsp', 'serve'],
        # [
        #     "node",
        #     "~/.emacs.d/var/lsp/server/eslint/unzipped/extension/server/out/eslintServer.js",
        #     "--stdio",
        # ],
    ]
