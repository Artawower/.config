import subprocess

def _wakatime_hook(cmd, rtn, out, ts):
    try:
        subprocess.Popen([
            '/opt/homebrew/bin/wakatime',
            '--plugin', 'xonsh-wakatime/1.0.0',
            '--entity-type', 'app',
            '--entity', 'Terminal',
            '--language', 'sh'
        ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except:
        pass

if hasattr(__xonsh__.builtins, 'events'):
    __xonsh__.builtins.events.on_postcommand(_wakatime_hook)
