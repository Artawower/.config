import json
from pathlib import Path
from xonsh.completers.tools import RichCompletion

def _package_json_scripts_completer(prefix, line, begidx, endidx, ctx):
    """Complete npm/pnpm/bun scripts from package.json"""
    
    words = line.split()
    if len(words) < 2:
        return None
    
    cmd = words[0]
    if cmd not in ['npm', 'pnpm', 'bun', 'pr', 'br', 'yarn']:
        return None
    
    if len(words) >= 2 and words[1] != 'run':
        if cmd in ['pr', 'br']:
            pass
        else:
            return None
    
    pkg_json = Path.cwd() / 'package.json'
    if not pkg_json.exists():
        return None
    
    try:
        data = json.loads(pkg_json.read_text())
        scripts = data.get('scripts', {})
        
        completions = set()
        for name, value in scripts.items():
            if name.startswith(prefix):
                completions.add(RichCompletion(
                    name,
                    display=f'{name}',
                    description=value[:50] if value else '',
                    append_space=True
                ))
        
        return completions if completions else None
    except:
        return None

__xonsh__.completers['package_json_scripts'] = _package_json_scripts_completer
__xonsh__.completers.move_to_end('package_json_scripts', last=False)
