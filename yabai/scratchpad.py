#!/usr/bin/env python3
import subprocess
import json
import sys
import time
import os
from dataclasses import dataclass
from typing import Optional
from pathlib import Path


STATE_DIR = Path('/tmp/yabai-scratchpads')


@dataclass(frozen=True)
class Paths:
    yabai: str = '/opt/homebrew/bin/yabai'
    wezterm: str = '/opt/homebrew/bin/wezterm'


@dataclass(frozen=True)
class ScratchpadConfig:
    name: str
    cmd: str = ''
    grid: str = '100:100:15:10:70:80'
    hidden_space: int = 15


SCRATCHPADS: dict[str, ScratchpadConfig] = {
    'term': ScratchpadConfig(
        name='term',
        cmd='',
        grid='100:100:15:10:70:80',
    ),
    'htop': ScratchpadConfig(
        name='htop',
        cmd='htop',
        grid='100:100:20:15:60:70',
    ),
}


class Yabai:
    def __init__(self, path: str = Paths.yabai):
        self._path = path

    def _run(self, *args: str) -> subprocess.CompletedProcess:
        return subprocess.run([self._path, '-m', *args], capture_output=True, text=True)

    def query_windows(self) -> list[dict]:
        result = self._run('query', '--windows')
        return json.loads(result.stdout) if result.stdout else []

    def query_spaces(self) -> list[dict]:
        result = self._run('query', '--spaces')
        return json.loads(result.stdout) if result.stdout else []

    def current_space(self) -> int:
        for space in self.query_spaces():
            if space.get('has-focus'):
                return space['index']
        return 1

    def find_window(self, predicate) -> Optional[dict]:
        return next((w for w in self.query_windows() if predicate(w)), None)

    def window_set_float(self, wid: int, floating: bool) -> None:
        win = self.find_window(lambda w: w['id'] == wid)
        if win and win.get('is-floating', False) != floating:
            self._run('window', str(wid), '--toggle', 'float')

    def window_set_grid(self, wid: int, grid: str) -> None:
        self._run('window', str(wid), '--grid', grid)

    def window_set_space(self, wid: int, space: int) -> None:
        self._run('window', str(wid), '--space', str(space))

    def window_focus(self, wid: int) -> None:
        self._run('window', str(wid), '--focus')

    def window_minimize(self, wid: int) -> None:
        self._run('window', str(wid), '--minimize')

    def window_deminimize(self, wid: int) -> None:
        self._run('window', str(wid), '--deminimize')


class Scratchpad:
    def __init__(self, config: ScratchpadConfig, yabai: Yabai, paths: Paths = Paths()):
        self.config = config
        self.yabai = yabai
        self.paths = paths
        STATE_DIR.mkdir(exist_ok=True)

    @property
    def state_file(self) -> Path:
        return STATE_DIR / f'{self.config.name}.id'

    def load_window_id(self) -> Optional[int]:
        if self.state_file.exists():
            try:
                return int(self.state_file.read_text().strip())
            except (ValueError, OSError):
                return None
        return None

    def save_window_id(self, wid: int) -> None:
        self.state_file.write_text(str(wid))

    def clear_window_id(self) -> None:
        self.state_file.unlink(missing_ok=True)

    def find_window(self) -> Optional[dict]:
        wid = self.load_window_id()
        if wid is None:
            return None
        win = self.yabai.find_window(lambda w: w['id'] == wid)
        if win is None:
            self.clear_window_id()
        return win

    def is_visible(self, win: dict) -> bool:
        return not win.get('is-minimized', False)

    def launch(self) -> Optional[int]:
        old_ids = {w['id'] for w in self.yabai.query_windows()}

        if self.config.cmd:
            subprocess.Popen([
                self.paths.wezterm, 'start', '--always-new-process', '--',
                '/bin/zsh', '-c', self.config.cmd
            ])
        else:
            subprocess.Popen([
                self.paths.wezterm, 'start', '--always-new-process'
            ])

        for _ in range(30):
            time.sleep(0.1)
            for win in self.yabai.query_windows():
                if win['id'] not in old_ids and win.get('app') in ('wezterm-gui', 'WezTerm'):
                    return win['id']
        return None

    def show(self, wid: int, space: int) -> None:
        self.yabai.window_deminimize(wid)
        self.yabai.window_set_space(wid, space)
        self.yabai.window_set_float(wid, True)
        self.yabai.window_set_grid(wid, self.config.grid)
        self.yabai.window_focus(wid)

    def hide(self, wid: int) -> None:
        self.yabai.window_minimize(wid)

    def is_on_current_space(self, win: dict, current_space: int) -> bool:
        return win.get('space', 0) == current_space

    def toggle(self) -> None:
        current_space = self.yabai.current_space()
        win = self.find_window()

        if not win:
            wid = self.launch()
            if wid:
                self.save_window_id(wid)
                self.show(wid, current_space)
            return

        wid = win['id']
        is_minimized = win.get('is-minimized', False)
        on_current = self.is_on_current_space(win, current_space)

        if is_minimized or not on_current:
            self.show(wid, current_space)
        else:
            self.hide(wid)


def main() -> None:
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} toggle <name>")
        print(f"Available: {', '.join(SCRATCHPADS.keys())}")
        sys.exit(1)

    action, name = sys.argv[1], sys.argv[2]

    if name not in SCRATCHPADS:
        print(f"Unknown scratchpad: {name}")
        print(f"Available: {', '.join(SCRATCHPADS.keys())}")
        sys.exit(1)

    config = SCRATCHPADS[name]
    scratchpad = Scratchpad(config, Yabai(), Paths())

    if action == 'toggle':
        scratchpad.toggle()
    else:
        print(f"Unknown action: {action}")
        sys.exit(1)


if __name__ == '__main__':
    main()
