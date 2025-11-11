import json
import hashlib
from pathlib import Path

COLORS = ["blue", "cyan", "green", "purple", "yellow", "red", "bright-blue", "bright-cyan", "bright-green", "bright-magenta", "bright-yellow"]

# True Color RGB codes (same colors everywhere)
COLOR_HEX = {
    "blue": "#5294e2",
    "cyan": "#4dd0e1",
    "green": "#81c784",
    "purple": "#ba68c8",
    "magenta": "#ba68c8",
    "yellow": "#ffd54f",
    "red": "#e57373",
    "bright-blue": "#64b5f6",
    "bright-cyan": "#4dd0e1",
    "bright-green": "#aed581",
    "bright-magenta": "#ce93d8",
    "bright-yellow": "#fff176"
}

def _hex_to_rgb_escape(hex_color):
    """Convert hex color to True Color escape sequence"""
    hex_color = hex_color.lstrip('#')
    r, g, b = int(hex_color[0:2], 16), int(hex_color[2:4], 16), int(hex_color[4:6], 16)
    return f'\033[38;2;{r};{g};{b}m'

RESET = '\033[0m'

_markers_cache = None

def _load_markers():
    global _markers_cache
    config_file = Path.home() / '.config/xonsh/project-markers.json'
    if config_file.exists():
        _markers_cache = json.loads(config_file.read_text())
    else:
        _markers_cache = {}
    return _markers_cache

def _save_markers(markers):
    config_file = Path.home() / '.config/xonsh/project-markers.json'
    config_file.write_text(json.dumps(markers, indent=2))

def _get_git_root():
    cwd = Path.cwd()
    for parent in [cwd] + list(cwd.parents):
        if (parent / '.git').exists():
            return parent
    return None

def _get_project_root():
    git_root = _get_git_root()
    if git_root:
        return git_root
    
    cwd = Path.cwd()
    projects_dir = Path.home() / 'projects'
    try:
        if projects_dir in cwd.parents or cwd == projects_dir:
            relative = cwd.relative_to(projects_dir)
            if relative.parts:
                return projects_dir / relative.parts[0]
    except:
        pass
    
    return None

def _assign_color(project_name):
    hash_val = int(hashlib.md5(project_name.encode()).hexdigest(), 16)
    return COLORS[hash_val % len(COLORS)]

def _update_project_marker():
    if _markers_cache is None:
        _load_markers()
    
    markers = _markers_cache
    project_root = _get_project_root()
    
    if not project_root:
        $PROJECT_MARKER = ''
        return
    
    project_path = str(project_root)
    
    if project_path not in markers:
        markers[project_path] = {
            'color': _assign_color(project_root.name),
            'marker': '■'
        }
        _save_markers(markers)
    
    config = markers[project_path]
    color_name = config.get('color', 'blue')
    hex_color = COLOR_HEX.get(color_name, '#5294e2')
    rgb_escape = _hex_to_rgb_escape(hex_color)
    marker = config.get('marker', '■')
    $PROJECT_MARKER = f' {rgb_escape}{marker}{RESET} '
    
    # Update zellij border color by changing theme in config
    import os
    import re
    if 'ZELLIJ' in os.environ:
        # Update theme file (green = active pane border color)
        theme_file = Path.home() / '.config/zellij/themes/project-dynamic.kdl'
        theme_content = f'''themes {{
    project-dynamic {{
        fg "#c6d0f5"
        bg "#303446"
        black "#51576d"
        red "#e78284"
        green "{hex_color}"
        yellow "#e5c890"
        blue "#8caaee"
        magenta "#f4b8e4"
        cyan "#81c8be"
        white "#b5bfe2"
        orange "#ef9f76"
    }}
}}'''
        
        try:
            theme_file.write_text(theme_content)
            
            # Touch config.kdl to trigger zellij reload
            import time
            config_file = Path.home() / '.config/zellij/config.kdl'
            if config_file.exists():
                content = config_file.read_text()
                # Add/update timestamp comment to trigger file change
                import re
                timestamp = str(int(time.time()))
                if '// project-marker-ts:' in content:
                    content = re.sub(r'// project-marker-ts:\d+', f'// project-marker-ts:{timestamp}', content)
                else:
                    content += f'\n// project-marker-ts:{timestamp}\n'
                config_file.write_text(content)
        except Exception as e:
            pass

@events.on_chdir
def _on_chdir(olddir, newdir, **kw):
    _update_project_marker()

_update_project_marker()
