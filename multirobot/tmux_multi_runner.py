#!/usr/bin/env python3
"""
Optimized tmux multi-runner for highlevel_demo and mc processes.

Improvements:
- Fixed shebang position and imports.
- Ensures tmux is available and session existence is checked.
- Creates one window per role (mc/demo) per robot in a single loop.
- Uses absolute paths relative to this script for run_mc.sh.
- Safer subprocess handling with check and error reporting.
- Proper signal handling and clean session kill.
"""

import os
import sys
import signal
import time
import shutil
import subprocess
from pathlib import Path

# Define ports: (state_port, cmd_port, local_port, dog_port, lowl_port)
PORT_PAIRS = [
    (25001, 25002, 25003, 25004, 25005),
    (25011, 25012, 25013, 25014, 25015),
    (25021, 25022, 25023, 25024, 25025),
]

SESSION_NAME = "highlevel_demo_session"

SCRIPT_DIR = Path(__file__).resolve().parent

def tmux_available():
    return shutil.which("tmux") is not None

def has_session(name):
    p = subprocess.run(["tmux", "has-session", "-t", name], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return p.returncode == 0

def kill_session(name):
    if has_session(name):
        subprocess.run(["tmux", "kill-session", "-t", name], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def create_window(session, window_name, first=False):
    if first:
        # create detached session with initial window name
        subprocess.run(["tmux", "new-session", "-d", "-s", session, "-n", window_name], check=True)
    else:
        subprocess.run(["tmux", "new-window", "-t", session, "-n", window_name], check=True)

def send_cmd_to_window(session, window_name, cmd):
    target = f"{session}:{window_name}"
    # send keys and press Enter (C-m)
    subprocess.run(["tmux", "send-keys", "-t", target, cmd, "C-m"], check=True)

def signal_handler(sig, frame):
    print("\nReceived signal, shutting down tmux session...")
    kill_session(SESSION_NAME)
    sys.exit(0)

def main():
    if not tmux_available():
        print("tmux not found in PATH. Please install tmux.", file=sys.stderr)
        sys.exit(2)

    # register handlers
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    # cleanup any old session
    kill_session(SESSION_NAME)
    time.sleep(0.2)

    first_window = True
    for idx, (state_port, cmd_port, local_port, dog_port, lowl_port) in enumerate(PORT_PAIRS):
        # mc window
        mc_window = f"mc_{local_port}"
        try:
            create_window(SESSION_NAME, mc_window, first=first_window)
        except subprocess.CalledProcessError:
            print(f"Failed to create tmux window '{mc_window}'", file=sys.stderr)
            kill_session(SESSION_NAME)
            sys.exit(1)

        mc_dir = (SCRIPT_DIR / ".." / "src" / "robot_mc").resolve()
        mc_cmd = f"cd {mc_dir} && ./run_mc.sh r {state_port} {cmd_port} {local_port} {dog_port} {lowl_port}"
        try:
            send_cmd_to_window(SESSION_NAME, mc_window, mc_cmd)
            print(f"Started mc: {mc_cmd} -> window '{mc_window}'")
        except subprocess.CalledProcessError:
            print(f"Failed to send mc command to '{mc_window}'", file=sys.stderr)

        # demo window
        demo_window = f"demo_{local_port}_{dog_port}"
        try:
            # subsequent windows are not the first
            create_window(SESSION_NAME, demo_window, first=False)
        except subprocess.CalledProcessError:
            print(f"Failed to create tmux window '{demo_window}'", file=sys.stderr)
            continue

        demo_cmd = f"python highlevel_demo.py --local-port {local_port} --dog-port {dog_port}"
        try:
            send_cmd_to_window(SESSION_NAME, demo_window, demo_cmd)
            print(f"Started demo: {demo_cmd} -> window '{demo_window}'")
        except subprocess.CalledProcessError:
            print(f"Failed to send demo command to '{demo_window}'", file=sys.stderr)

        first_window = False
        time.sleep(0.2)

    print(f"\nAll processes started in background tmux session '{SESSION_NAME}'.")
    print(f"Use: tmux attach -t {SESSION_NAME}")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        pass
    finally:
        kill_session(SESSION_NAME)

if __name__ == "__main__":
    main()
