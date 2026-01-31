#!/usr/bin/env python3
from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path


CONFIG_DIR = (
    Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
    / "project-launcher"
)


def list_projects() -> list[str]:
    if not CONFIG_DIR.is_dir():
        print(f"Missing config dir: {CONFIG_DIR}", file=sys.stderr)
        return []
    return sorted(
        p.name
        for p in CONFIG_DIR.iterdir()
        if p.is_dir() and not p.name.startswith(".")
    )


def choose_project(projects: list[str]) -> str:
    # Pick one menu command; wofi is great on Wayland.
    menu_cmd = [
        "wofi",
        "--conf",
        "/home/colino/.config/wofi/catppuccin-wofi/config",
        "--style",
        "/home/colino/.config/wofi/catppuccin-wofi/src/macchiato/style.css",
        "--dmenu",
        "-i",
        "-p",
        "Project",
    ]

    try:
        proc = subprocess.run(
            menu_cmd,
            input="\n".join(projects),
            text=True,
            capture_output=True,
            check=False,
        )
    except FileNotFoundError:
        print(f"Menu not found: {menu_cmd[0]}", file=sys.stderr)
        return ""

    return proc.stdout.strip()


def run_project_launch(project_name: str) -> int:
    project_dir = CONFIG_DIR / project_name
    launch_py = project_dir / "launch.py"
    if not launch_py.is_file():
        print(f"Missing {launch_py}", file=sys.stderr)
        return 2

    env = os.environ.copy()
    env["PROJECT_NAME"] = project_name
    env["PROJECT_DIR"] = str(project_dir)

    # Use sys.executable so you always run with your Python 3.13
    # Run from the project directory so relative paths in launch.py behave nicely.
    proc = subprocess.run(
        [sys.executable, str(launch_py)],
        cwd=str(project_dir),
        env=env,
    )
    return proc.returncode


def main() -> int:
    projects = list_projects()
    if not projects:
        print(f"No projects found in {CONFIG_DIR}", file=sys.stderr)
        return 1

    choice = choose_project(projects)
    if not choice:
        return 0  # user cancelled

    if choice not in projects:
        print(f"Invalid selection: {choice}", file=sys.stderr)
        return 1

    return run_project_launch(choice)


if __name__ == "__main__":
    raise SystemExit(main())
