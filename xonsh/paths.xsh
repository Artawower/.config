from pathlib import Path

$PATH.insert(0, str(Path.home() / '.local/share/uv/tools'))
$PATH.insert(0, str(Path.home() / '.volta/bin'))
$PATH.insert(0, str(Path.home() / '.config/bin'))
$PATH.insert(0, str(Path.home() / 'bin'))
$PATH.insert(0, str(Path.home() / 'go/bin'))
$PATH.insert(0, str(Path.home() / '.go/bin'))
$PATH.insert(0, str(Path.home() / '.cargo/bin'))
$PATH.insert(0, str(Path.home() / '.npm-global/bin'))
$PATH.insert(0, str(Path.home() / '.bun/bin'))
$PATH.insert(0, str(Path.home() / '.local/bin'))
$PATH.insert(0, str(Path.home() / '.orbstack/bin'))
$PATH.insert(0, str(Path.home() / 'dev/flutter/bin'))
$PATH.insert(0, str(Path.home() / 'tmp/lua-language-server/bin'))
$PATH.insert(0, str(Path.home() / '$ANDROID_SDK_ROOT/platform-tools'))
$PATH.insert(0, str(Path.home() / '$ANDROID_SDK_ROOT/cmdline-tools/latest/bin'))
$PATH.insert(0, str(Path.home() / 'Library/pnpm'))
$PATH.insert(0, '/opt/homebrew/bin')
$PATH.insert(0, '/opt/homebrew/sbin')
$PATH.insert(0, '/opt/homebrew/opt/node@22/bin')
$PATH.insert(0, '/opt/homebrew/opt/openjdk@11/bin')
$PATH.insert(0, '/opt/homebrew/opt/go/libexec/bin')
$PATH.insert(0, '/opt/homebrew/opt/llvm/bin')
$PATH.insert(0, '/opt/homebrew/opt/gnupg@2.2/bin')
$PATH.insert(0, '/opt/homebrew/opt/autoconf@2.69/bin')
$PATH.insert(0, '/opt/homebrew/opt/openssl@1.1/bin')
$PATH.insert(0, '/opt/homebrew/lib/node_modules/typescript/bin')
$PATH.insert(0, str(Path.home() / '.nix-profile/bin'))
$PATH.insert(0, '/nix/var/nix/profiles/default/bin')
$PATH.insert(0, str(Path.home() / '.local/bin'))

sdkman_base = Path.home() / '.sdkman/candidates'
if sdkman_base.exists():
    $PATH.insert(0, str(sdkman_base / 'java/current/bin'))
    $PATH.insert(0, str(sdkman_base / 'gradle/current/bin'))

$ANDROID_SDK_ROOT = '/opt/homebrew/share/android-commandlinetools'
$ANDROID_HOME = ($ANDROID_SDK_ROOT)
