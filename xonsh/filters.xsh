import re

def _grep_filter(args, stdin=None):
    """Filter by pattern (case-insensitive): ps aux | f emacs"""
    if not args:
        return
    
    pattern = re.compile(args[0], re.IGNORECASE)
    
    if stdin:
        for line in stdin:
            if isinstance(line, bytes):
                line = line.decode('utf-8', errors='ignore')
            if pattern.search(line):
                print(line.rstrip())

aliases['f'] = _grep_filter
