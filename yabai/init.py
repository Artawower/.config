#!/usr/bin/env python3
import subprocess
import json
import time
from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import Optional, Callable


@dataclass(frozen=True)
class Paths:
    yabai: str = '/opt/homebrew/bin/yabai'
    wezterm: str = '/opt/homebrew/bin/wezterm'
    xonsh: str = '/Users/darkawower/.nix-profile/bin/xonsh'
    zen: str = '/Applications/Twilight.app/Contents/MacOS/zen'
    notifier: str = '/opt/homebrew/bin/terminal-notifier'


@dataclass(frozen=True)
class WindowLayout:
    grid: str
    space: str
    floating: bool = True


class Yabai:
    def __init__(self, path: str = Paths.yabai):
        self._path = path

    def query_windows(self) -> list[dict]:
        result = subprocess.run(
            [self._path, '-m', 'query', '--windows'],
            capture_output=True, text=True
        )
        return json.loads(result.stdout) if result.stdout else []

    def set_floating(self, wid: int, floating: bool) -> None:
        win = self.find_window_by_id(wid)
        if win and win.get('is-floating', False) != floating:
            subprocess.run([self._path, '-m', 'window', str(wid), '--toggle', 'float'])

    def set_grid(self, wid: int, grid: str) -> None:
        subprocess.run([self._path, '-m', 'window', str(wid), '--grid', grid])

    def set_space(self, wid: int, space: str) -> None:
        subprocess.run([self._path, '-m', 'window', str(wid), '--space', space])

    def apply_layout(self, wid: int, layout: WindowLayout) -> None:
        self.set_floating(wid, layout.floating)
        self.set_grid(wid, layout.grid)
        self.set_space(wid, layout.space)

    def find_window_by_id(self, wid: int) -> Optional[dict]:
        return next((w for w in self.query_windows() if w['id'] == wid), None)

    def find_windows(self, predicate: Callable[[dict], bool]) -> list[dict]:
        return [w for w in self.query_windows() if predicate(w)]

    def find_window(self, predicate: Callable[[dict], bool]) -> Optional[dict]:
        return next((w for w in self.query_windows() if predicate(w)), None)


class WindowRule(ABC):
    def __init__(self, layout: WindowLayout, yabai: Yabai):
        self.layout = layout
        self.yabai = yabai

    @abstractmethod
    def find_existing(self) -> Optional[dict]:
        pass

    @abstractmethod
    def launch(self) -> None:
        pass

    def apply(self) -> None:
        existing = self.find_existing()
        if existing:
            self.yabai.apply_layout(existing['id'], self.layout)
            return
        self._launch_and_configure()

    def _launch_and_configure(self) -> None:
        old_ids = self._get_window_ids()
        self.launch()
        self._wait_and_configure(old_ids)

    def _get_window_ids(self) -> set[int]:
        return {w['id'] for w in self.yabai.find_windows(self._matches_app)}

    def _matches_app(self, win: dict) -> bool:
        return True

    def _wait_and_configure(self, old_ids: set[int], timeout: float = 4.0) -> None:
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            time.sleep(0.2)
            new_ids = self._get_window_ids() - old_ids
            if new_ids:
                self.yabai.apply_layout(new_ids.pop(), self.layout)
                return


class WeztermRule(WindowRule):
    def __init__(self, title: str, cmd: str, layout: WindowLayout, yabai: Yabai, paths: Paths = Paths()):
        super().__init__(layout, yabai)
        self.title = title
        self.cmd = cmd
        self.paths = paths

    def find_existing(self) -> Optional[dict]:
        return self.yabai.find_window(lambda w: w.get('title') == self.title)

    def launch(self) -> None:
        full_cmd = f'echo -ne "\\033]2;{self.title}\\007"; {self.cmd}'
        subprocess.Popen([
            self.paths.wezterm, "start", "--",
            self.paths.xonsh, "-c", full_cmd
        ])

    def _matches_app(self, win: dict) -> bool:
        return win.get('app') in ('wezterm-gui', 'WezTerm')


@dataclass(frozen=True)
class EnsureApp:
    app: str
    launch_cmd: list[str] | str

    def is_running(self, yabai: Yabai) -> bool:
        return yabai.find_window(lambda w: w.get('app') == self.app) is not None

    def launch(self) -> None:
        if isinstance(self.launch_cmd, str):
            subprocess.Popen(['open', '-a', self.launch_cmd])
        else:
            subprocess.Popen(self.launch_cmd)


class BrowserRule(WindowRule):
    def __init__(self, app: str, url: str, title_pattern: str, layout: WindowLayout, yabai: Yabai, paths: Paths = Paths()):
        super().__init__(layout, yabai)
        self.app = app
        self.url = url
        self.title_pattern = title_pattern
        self.paths = paths

    def find_existing(self) -> Optional[dict]:
        return self.yabai.find_window(
            lambda w: w.get('app') == self.app and self.title_pattern in w.get('title', '')
        )

    def launch(self) -> None:
        subprocess.Popen([self.paths.zen, '--new-window', self.url])

    def _matches_app(self, win: dict) -> bool:
        return win.get('app') == self.app


@dataclass
class AppConfig:
    rules: list[WindowRule]
    ensure_apps: list[EnsureApp]
    yabai: Yabai
    notifier_path: str = Paths.notifier

    def apply_all(self) -> None:
        for rule in self.rules:
            rule.apply()

    def ensure_running(self) -> None:
        for app in self.ensure_apps:
            if not app.is_running(self.yabai):
                app.launch()

    def configure_existing(self) -> None:
        for rule in self.rules:
            existing = rule.find_existing()
            if existing:
                rule.yabai.apply_layout(existing['id'], rule.layout)

    def notify(self, msg: str) -> None:
        subprocess.run([self.notifier_path, '-title', 'Init Apps', '-message', msg])


def create_config() -> AppConfig:
    yabai = Yabai()
    paths = Paths()

    rules = [
        WeztermRule(
            title='cava',
            cmd='cava',
            layout=WindowLayout(grid='100:100:8:62:84:37', space='6'),
            yabai=yabai,
            paths=paths,
        ),
        WeztermRule(
            title='WIN_PIPES.SH',
            cmd='pipes.sh',
            layout=WindowLayout(grid='100:100:2:10:40:40', space='6'),
            yabai=yabai,
            paths=paths,
        ),
        BrowserRule(
            app='Twilight',
            url='https://www.youtube.com/watch?v=IUARG6yQKvE',
            title_pattern='YouTube',
            layout=WindowLayout(grid='100:100:48:0:50:40', space='6'),
            yabai=yabai,
            paths=paths,
        ),
    ]

    ensure_apps = [
        EnsureApp(app='Telegram', launch_cmd='Telegram'),
        EnsureApp(app='Mattermost', launch_cmd='Mattermost'),
        EnsureApp(app='ChatGPT', launch_cmd='ChatGPT'),
        EnsureApp(app='OrbStack', launch_cmd='OrbStack'),
EnsureApp(app='Emacs', launch_cmd='EmacsClient.app'),
    ]

    return AppConfig(
        rules=rules,
        ensure_apps=ensure_apps,
        yabai=yabai,
        notifier_path=paths.notifier,
    )


def main() -> None:
    config = create_config()
    config.ensure_running()
    config.apply_all()
    time.sleep(2)
    config.configure_existing()
    config.notify("All applications initialized.")


if __name__ == "__main__":
    main()
