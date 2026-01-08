"""Angular HTML/TypeScript preset: typescript-language-server + eslint."""

def servers():
    return [
        ['ngserver', "--stdio", "--tsProbeLocations", ".", "--ngProbeLocations", "."],
        ["vscode-html-language-server", '--stdio']
    ]
