#!/usr/bin/env fish
# Ensure Go binaries are on PATH for fish
if type -q fish_add_path
    fish_add_path $HOME/go/bin
    fish_add_path $HOME/.go/bin
else
    set -gx PATH $HOME/go/bin $HOME/.go/bin $PATH
end

