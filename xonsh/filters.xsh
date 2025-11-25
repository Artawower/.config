import re
import subprocess

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

def pkill_interactive(args):
    """Search and kill processes interactively: pki pattern"""
    if not args:
        print("Usage: pki <pattern>")
        return
    
    pattern = args[0]
    
    result = subprocess.run(['ps', 'aux'], capture_output=True, text=True)
    lines = result.stdout.split('\n')
    
    pattern_re = re.compile(pattern, re.IGNORECASE)
    
    matched_processes = []
    for line in lines[1:]:
        if line.strip() and pattern_re.search(line):
            parts = line.split(None, 10)
            if len(parts) >= 11:
                pid = parts[1]
                process_name = parts[10]
                matched_processes.append((pid, process_name))
    
    if not matched_processes:
        print(f"No processes found matching '{pattern}'")
        return
    
    print(f"\nFound {len(matched_processes)} process(es):\n")
    for pid, command in matched_processes:
        print(f"[{pid}] {command}")
    
    print(f"\n\033[1;31mKill these {len(matched_processes)} process(es)?\033[0m [Y/n]: ", end='', flush=True)
    response = input().strip().lower()
    
    if response in ['y', 'yes', '']:
        killed = []
        failed = []
        for pid, command in matched_processes:
            try:
                subprocess.run(['kill', pid], check=True)
                killed.append(f"{pid}")
            except subprocess.CalledProcessError:
                failed.append(f"{pid}")
        
        if killed:
            print(f"\n\033[1;32mKilled:\033[0m {len(killed)} process(es)")
            for pid in killed:
                print(f"  ✓ PID {pid}")
        
        if failed:
            print(f"\n\033[1;31mFailed to kill:\033[0m {len(failed)} process(es)")
            for pid in failed:
                print(f"  ✗ PID {pid}")
    else:
        print("\nCancelled.")

aliases['f'] = _grep_filter
aliases['pki'] = pkill_interactive
