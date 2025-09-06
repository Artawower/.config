#!/bin/bash
# OpenCode wrapper with custom key remapping

# Run opencode with custom terminal settings
stty intr '^O'  # Change interrupt from Ctrl+C to Ctrl+O
stty eof '^P'   # Change EOF from Ctrl+D to Ctrl+P

exec opencode "$@"