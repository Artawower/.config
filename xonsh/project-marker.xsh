import json
import hashlib
from pathlib import Path

COLORS = ["blue", "cyan", "green", "purple", "yellow", "red", "bright-blue", "bright-cyan", "bright-green", "bright-magenta", "bright-yellow"]
ANSI_COLORS = {
    "blue": "\033[34m",
    "cyan": "\033[36m",
    "green": "\033[32m",
    "purple": "\033[35m",
    "yellow": "\033[33m",
    "red": "\033[31m",
    "bright-blue": "\033[94m",
    "bright-cyan": "\033[96m",
    "bright-green": "\033[92m",
    "bright-magenta": "\033[95m",
    "bright-yellow": "\033[93m",
    "reset": "\033[0m"
}

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
    color = ANSI_COLORS.get(config.get('color', 'blue'), '')
    marker = config.get('marker', '■')
    $PROJECT_MARKER = f' {color}{marker}{ANSI_COLORS["reset"]} '

@events.on_chdir
def _on_chdir(olddir, newdir, **kw):
    _update_project_marker()

_update_project_marker()
