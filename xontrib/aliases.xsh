import datetime

import xonsh.tools as _xt


def _traceback_on():
    $XONSH_SHOW_TRACEBACK = True
aliases['traceback_on'] = _traceback_on


def _import_local():
    import sys
    sys.path.append($(pwd).strip())
aliases['import_local'] = _import_local


def _tmx(args, stdin=None):
    tmux attach -t @(args[0]) or tmux new -s @(args[0])
aliases['tmx'] = _tmx


def _now(args, stdin=None):
    return datetime.datetime.now().isoformat()
aliases['now'] = _now


aliases['ll'] = 'ls -l'
aliases['la'] = 'ls -la'

if _xt.ON_DARWIN:
    aliases['battery']    = 'pmset -g'
