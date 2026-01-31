#!/usr/bin/env python3
from __future__ import annotations

import os
import subprocess
from pathlib import Path


def sh(cmd: list[str], *, check: bool = True) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, check=check)


def tmux_has_session(name: str) -> bool:
    return (
        subprocess.run(
            ["tmux", "has-session", "-t", name],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        ).returncode
        == 0
    )


def tmux_ensure_session(name: str, project_dir: str) -> None:
    if tmux_has_session(name):
        return
    sh(["tmuxp", "load", "-d", project_dir + "/session.yaml"])


def launch_terminal(session) -> None:
    cmd = ["tmux", "attach", "-t", session]

    subprocess.Popen(
        [
            "kitty",
            "--title",
            f"tmux:{session}",
            "--",
            *cmd,
        ],
        start_new_session=True,
    )


def main() -> int:
    session = os.environ.get("PROJECT_NAME", "api")
    project_dir = os.environ.get("PROJECT_DIR", "~/")

    tmux_ensure_session(session, project_dir)
    launch_terminal(session)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
