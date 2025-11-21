from pathlib import Path

ENV_FILES = [".env", ".env.local"]

@events.on_chdir
def load_dotenv(olddir, newdir, **_):
    new_path = Path(newdir)
    for fname in ENV_FILES:
        env_file = new_path / fname
        if not env_file.is_file():
            continue
        try:
            for line in env_file.read_text().splitlines():
                line = line.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                key, value = line.split("=", 1)
                __xonsh__.env[key.strip()] = value.strip()
        except Exception as e:
            print(f"[dotenv] failed to read {env_file}: {e}")
