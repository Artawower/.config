#!/usr/bin/env python3
"""jj-bisect: Interactive bisect for Jujutsu VCS.

Launches jj bisect run with an interactive shell for manual testing.
"""

import curses
import subprocess
import sys
from dataclasses import dataclass
from typing import Optional


@dataclass
class Revision:
    id: str
    description: str
    tags: list[str]


def run_jj(args: list[str], check: bool = True) -> str:
    result = subprocess.run(["jj"] + args, capture_output=True, text=True, check=check)
    return result.stdout


def get_revisions(limit: int = 200) -> list[Revision]:
    """Get recent revisions."""
    output = run_jj(
        [
            "log",
            "--no-graph",
            "-r",
            "::@",
            "--limit",
            str(limit),
            "--template",
            r'commit_id.short() ++ "\x00" ++ description.first_line() ++ "\x00" ++ tags.join(" ") ++ "\n"',
        ]
    )

    revisions = []
    for line in output.strip().split("\n"):
        if not line.strip():
            continue
        parts = line.split("\x00")
        if len(parts) >= 2:
            rev_id = parts[0]
            desc = parts[1] if len(parts) > 1 else "(empty)"
            tags = parts[2].split() if len(parts) > 2 and parts[2].strip() else []
            if not desc or desc == "@":
                continue
            revisions.append(Revision(id=rev_id, description=desc, tags=tags))
    return revisions


def init_colors():
    """Initialize terminal colors - transparent/terminal bg."""
    curses.use_default_colors()
    # Color pairs: (foreground, background) - use -1 for terminal's default bg
    curses.init_pair(1, curses.COLOR_WHITE, -1)  # Normal text
    curses.init_pair(2, curses.COLOR_CYAN, -1)  # Selected
    curses.init_pair(3, curses.COLOR_CYAN, -1)  # Header
    curses.init_pair(4, curses.COLOR_YELLOW, -1)  # Search match
    curses.init_pair(5, curses.COLOR_CYAN, -1)  # Search active
    curses.init_pair(6, curses.COLOR_RED, -1)  # Error
    curses.init_pair(7, curses.COLOR_GREEN, -1)  # Tags

    return {
        "normal": curses.color_pair(1) | curses.A_BOLD,
        "selected": curses.color_pair(2) | curses.A_BOLD | curses.A_UNDERLINE,
        "header": curses.color_pair(3) | curses.A_BOLD,
        "search": curses.color_pair(4),
        "search_active": curses.color_pair(5) | curses.A_BOLD,
        "error": curses.color_pair(6),
        "tag": curses.color_pair(7),
        "bold": curses.A_BOLD,
    }


def select_revision(
    stdscr, revisions: list[Revision], title: str
) -> Optional[Revision]:
    """Interactive revision selector with search and hjkl navigation."""
    curses.curs_set(0)
    stdscr.keypad(True)
    curses.noecho()

    colors = init_colors()
    curses.curs_set(0)

    current = 0
    offset = 0
    height, width = stdscr.getmaxyx()
    page_size = height - 7

    # Search state
    search_mode = False
    search_text = ""
    filtered = revisions[:]

    def redraw():
        nonlocal offset
        stdscr.clear()
        height, width = stdscr.getmaxyx()

        # Title
        stdscr.addstr(0, 0, f" {title} ", colors["header"])
        if search_mode:
            stdscr.addstr(0, width - 15, " [SEARCH] ", colors["search_active"])
        stdscr.addstr(1, 0, "─" * (width - 1))

        # Items
        visible = filtered if search_mode else revisions
        vis_len = min(page_size, len(visible) - offset)

        for i in range(vis_len):
            idx = offset + i
            rev = visible[idx]
            y = 2 + i

            # Truncate to fit
            avail = width - 4
            tag_str = f" [{', '.join(rev.tags)}]" if rev.tags else ""
            max_desc = avail - 14 - len(tag_str)
            line = f" {rev.id[:12]} | {rev.description[:max_desc]}{tag_str}"

            style = colors["selected"] if idx == current else colors["normal"]

            # Highlight search match
            if (
                search_mode
                and search_text.lower() in (rev.description + rev.id).lower()
            ):
                stdscr.addstr(y, 0, line[:avail], style)
            else:
                stdscr.addstr(y, 0, line[:avail], style)

        # Search input line
        if search_mode:
            stdscr.addstr(
                height - 3, 0, f" Search: {search_text}_", colors["search_active"]
            )

        # Status bar
        count = len(visible)
        nav = "j↓/k↑  space PgUp/PgDn  Home/End  [/]search  Enter=select  q=quit"
        if search_mode:
            nav = "Esc=cancel  Enter=select"
        stdscr.addstr(height - 1, 0, nav[: width - 1], colors["normal"])
        status = f"{offset + 1}-{min(offset + page_size, count)}/{count}"
        stdscr.addstr(height - 1, width - len(status) - 1, status)

        stdscr.refresh()

    # Initial draw
    redraw()

    while True:
        key = stdscr.getch()

        visible = filtered if search_mode else revisions
        count = len(visible)

        if search_mode:
            if key in [27, curses.KEY_EXIT]:  # Escape
                search_mode = False
                search_text = ""
                filtered = revisions[:]
                if current >= len(filtered):
                    current = max(0, len(filtered) - 1)
                if current < offset:
                    offset = max(0, current - page_size // 2)
            elif key in [curses.KEY_BACKSPACE, 127, 8]:
                search_text = search_text[:-1]
                if search_text:
                    q = search_text.lower()
                    filtered = [
                        r
                        for r in revisions
                        if q in r.description.lower() or q in r.id.lower()
                    ]
                else:
                    filtered = revisions[:]
                current = 0
                offset = 0
            elif 32 <= key <= 126:  # Printable
                search_text += chr(key)
                q = search_text.lower()
                filtered = [
                    r
                    for r in revisions
                    if q in r.description.lower() or q in r.id.lower()
                ]
                current = 0
                offset = 0
            elif key in [curses.KEY_UP, ord("k")]:
                current = max(0, current - 1)
                if current < offset:
                    offset = current
            elif key in [curses.KEY_DOWN, ord("j")]:
                current = min(count - 1, current + 1)
                if current >= offset + page_size:
                    offset = current - page_size + 1
            elif key in [ord("\n"), ord("\r")]:
                if visible:
                    return visible[current]
            redraw()
            continue

        # Navigation: j/k (vim) or arrows, h/l=Home/End, g/G=Home/End, space/C-z=PgUp, C-f/C-d=PgDn
        if key in [curses.KEY_UP, ord("k"), ord("l")]:
            # l=k for vim style since we're horizontal-nei
            current = max(0, current - 1)
            if current < offset:
                offset = current
        elif key in [curses.KEY_DOWN, ord("j"), ord("n")]:
            # j=n for vim style since we're horizontal-nei
            current = min(count - 1, current + 1)
            if current >= offset + page_size:
                offset = current - page_size + 1
        elif key in [curses.KEY_PPAGE, ord("b"), ord("u")]:
            current = max(0, current - page_size)
            offset = max(0, offset - page_size)
        elif key in [curses.KEY_NPAGE, ord("f"), ord("d")]:
            current = min(count - 1, current + page_size)
            offset = min(count - page_size, offset + page_size)
        elif key in [curses.KEY_HOME, ord("g"), ord("h")]:
            current = 0
            offset = 0
        elif key in [curses.KEY_END, ord("G")]:
            current = count - 1
            offset = max(0, count - page_size)
        elif key in [curses.KEY_END, ord("G")]:
            current = count - 1
            offset = max(0, count - page_size)
        elif key == ord("/"):
            search_mode = True
            search_text = ""
            filtered = revisions[:]
        elif key in [ord("\n"), ord("\r")]:
            if visible:
                return visible[current]
        elif key in [ord("q"), ord("Q"), 27]:
            return None

        redraw()


def main(stdscr):
    good_rev = None
    bad_rev = None

    args = sys.argv[1:]
    if len(args) >= 1:
        bad_rev = args[0]
    if len(args) >= 2:
        good_rev = args[1]

    if not bad_rev or not good_rev:
        stdscr.clear()
        stdscr.addstr(0, 0, " jj-bisect - Loading revisions... ")
        stdscr.refresh()

        try:
            revisions = get_revisions(200)
        except subprocess.CalledProcessError as e:
            print(f"Error: {e.stderr}", file=sys.stderr)
            sys.exit(1)

        if not revisions:
            print("No revisions found", file=sys.stderr)
            sys.exit(1)

        # Select bad
        if not bad_rev:
            result = select_revision(stdscr, revisions, "Select BAD revision (broken)")
            if not result:
                return
            bad_rev = result.id

        # Select good
        if not good_rev:
            result = select_revision(
                stdscr,
                revisions,
                f"BAD: {bad_rev[:12]} | Select GOOD revision (working)",
            )
            if not result:
                return
            good_rev = result.id

    curses.endwin()

    if bad_rev == good_rev:
        print("Bad and good must be different", file=sys.stderr)
        sys.exit(1)

    print("\n" + "=" * 50)
    print(f"  BAD (broken):   {bad_rev}")
    print(f"  GOOD (working): {good_rev}")
    print("=" * 50)
    print("\n  y/<Enter> = Good (works)")
    print("  n         = Bad (broken)")
    print("  s         = Skip this revision")
    print("  q         = Quit bisect")
    print("\n  $JJ_BISECT_TARGET = revision being tested")
    print()

    test_cmd = [
        "bash",
        "-c",
        'read -p "Work? [y/n/s/q] " -n 1; echo; '
        'case "$REPLY" in y|""|" ") exit 0 ;; n) exit 1 ;; s) exit 125 ;; q) exit 130 ;; esac',
    ]

    try:
        run_jj(
            [
                "bisect",
                "run",
                "--range",
                f"{bad_rev}..{good_rev}",
                "--",
            ]
            + test_cmd,
            check=False,
        )
    except subprocess.CalledProcessError as e:
        if e.returncode == 130:
            print("\nBisect cancelled.")
        else:
            print(f"\nBisect failed (exit {e.returncode})", file=sys.stderr)


if __name__ == "__main__":
    curses.wrapper(main)
