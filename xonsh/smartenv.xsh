#!/usr/bin/env xonsh
from pathlib import Path
import platform

STORAGE_PATH = Path.home() / ".global_env"


# ---------- storage ----------

def load_storage():
    data = {}
    if STORAGE_PATH.exists():
        for line in STORAGE_PATH.read_text().splitlines():
            if "=" in line:
                k, v = line.split("=", 1)
                data[k] = v
    return data


def save_storage(storage):
    STORAGE_PATH.write_text(
        "\n".join(f"{k}={v}" for k, v in storage.items())
    )


# ---------- system ----------


def set_system_env(key, value):
    if platform.system() == "Darwin":
        $(launchctl setenv @(key) @(value))
    else:
        $(systemctl --user set-environment @(f"{key}={value}"))
    __xonsh__.env[key] = value


def unset_system_env(key):
    if platform.system() == "Darwin":
        $(launchctl unsetenv @(key))
    else:
        $(systemctl --user unset-environment @(key))
    __xonsh__.env.pop(key, None)


# ---------- public api ----------

def list_env():
    storage = load_storage()

    if not storage:
        print("Storage is empty")
        return

    print(f"{'VARIABLE':<25} VALUE")
    print("-" * 40)
    for k, v in storage.items():
        print(f"{k:<25} {v}")


def set_env(key, value):
    storage = load_storage()
    storage[key] = value

    set_system_env(key, value)
    save_storage(storage)

    print(f"✔ {key} set")


def del_env(key):
    storage = load_storage()

    if key not in storage:
        print(f"✘ {key} not found")
        return

    storage.pop(key)

    unset_system_env(key)
    save_storage(storage)

    print(f"✔ {key} removed")


def boot_env():
    storage = load_storage()
    for k, v in storage.items():
        set_system_env(k, v)

    if __xonsh__.env.get("XONSH_INTERACTIVE"):
        print("✔ environment restored")



boot_env()
