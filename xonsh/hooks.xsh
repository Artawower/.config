import subprocess

def _wakatime_hook(cmd, rtn, out, ts):
    try:
        command = cmd if isinstance(cmd, str) else ' '.join(cmd) if cmd else 'terminal'
        subprocess.Popen([
            '/opt/homebrew/bin/wakatime',
            '--plugin', 'xonsh-wakatime/1.0.0',
            '--write',
            '--entity-type', 'domain',
            '--entity', 'terminal',
            '--project', command,
            '--language', 'shell'
        ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except:
        pass

if hasattr(__xonsh__.builtins, 'events'):
    __xonsh__.builtins.events.on_postcommand(_wakatime_hook)
