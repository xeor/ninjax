import os
import builtins
import platform
import getpass
import subprocess

from xonsh.prompt import gitstatus, env, cwd

from . import helpers

def _true_false_color(val):
    return '{GREEN}' if val else '{BOLD_RED}'

def _prompt_part(color, value, *, name=None, trailing_space=True):
    if not value:
        return ''

    suffix = ' ' if trailing_space else ''
    if name is not None:
        name = f'{name}:' if name else name
        return '{' + color + '}[' + name + str(value) + '{' + color + '}]{NO_COLOR}' + suffix
    else:
        return '{' + color + '}' + str(value) + '{' + color + '}{NO_COLOR}' + suffix

def _user():
    username = getpass.getuser()
    if os.getuid() == 0:
        color = 'RED'
    else:
        color = 'GREEN'
    return _prompt_part(color, username, trailing_space=False)
$PROMPT_FIELDS['user'] = _user

def _http_proxy():
    color = 'RED'
    if [i for i in os.environ.keys() if i.lower() in ['http_proxy', 'https_proxy']]:
        color = 'GREEN'
    return _prompt_part(color, '@', trailing_space=False)
$PROMPT_FIELDS['at'] = _http_proxy

def _hostname():
    hostname = platform.node().split('.')[0]
    termproc, termspawner = helpers.login_process()
    if termspawner in ['sshd']:
        color = 'CYAN'
    elif termspawner in ['Terminal']:
        color = 'GREEN'
    else:
        color = 'YELLOW'

    return _prompt_part(color, hostname, trailing_space=False)
$PROMPT_FIELDS['hostname'] = _hostname

def _venv():
    return _prompt_part('PURPLE', env.env_name(pre_chars='', post_chars=''), name='venv')
$PROMPT_FIELDS['venv'] = _venv

def _git():
    gittext = gitstatus.gitstatus_prompt()
    if gittext:
        return _prompt_part('CYAN', gittext, name='git')
$PROMPT_FIELDS['git'] = _git

def _curdir():
    current = cwd._replace_home_cwd()
    current_trunc = cwd._dynamically_collapsed_pwd()
    if current == current_trunc:
        trunc_color = 'GREEN'
    else:
        trunc_color = 'YELLOW'

    if os.access(builtins.__xonsh_env__['PWD'], os.W_OK):
        access_color = 'GREEN'
    else:
        access_color = 'RED'

    dirstring = '{' + access_color + '}' + current_trunc + '{' + access_color + '}{NO_COLOR}'
    return '{' + trunc_color + '}{{ {NO_COLOR}' + dirstring + '{' + trunc_color + '} }}{NO_COLOR}'
$PROMPT_FIELDS['curdir'] = _curdir


def _return_code():
    code = __xonsh_history__.rtns[-1] if __xonsh_history__ else 0
    return _prompt_part('RED', code, name='rc')
$PROMPT_FIELDS['rc'] = _return_code

def _timeinfo():
    try:
        start, end = __xonsh_history__.tss[-1]
    except IndexError:
        # First command...
        return ''

    timetaken = int(end - start)
    if timetaken >= 10:
        return _prompt_part('YELLOW', helpers.human_readable_time(timetaken), name='cmdtime')
$PROMPT_FIELDS['timed'] = _timeinfo

def _bg():
    bgjobs = $(jobs -r | wc -l | sed -e 's/[^0-9]//g')
    if bgjobs:
        bgjobs = int(bgjobs)
        return _prompt_part('RED' if bgjobs >= 4 else 'YELLOW', bgjobs, name='bg')
$PROMPT_FIELDS['bg'] = _bg

def _stp():
    stpjobs = $(jobs -s | wc -l | sed -e 's/[^0-9]//g')
    if stpjobs:
        stpjobs = int(stpjobs)
        return _prompt_part('RED' if stpjobs >= 2 else 'YELLOW', stpjobs, name='stp')
$PROMPT_FIELDS['stp'] = _stp

def _tmux():
    tmuxcheck = !(which tmux)
    if tmuxcheck.returncode != 0:
        return ''

    try:
        attached = len([i for i in subprocess.check_output([tmuxcheck.output, 'ls'], stderr=subprocess.DEVNULL).splitlines() if b'(attached)' in i])
    except subprocess.CalledProcessError:
        return ''

    return _prompt_part('RED' if attached >= 2 else 'YELLOW', attached, name='tmux')
$PROMPT_FIELDS['tmux'] = _tmux


# https://github.com/xeor/ninjab/wiki/parts-4_prompt

$PROMPT = ''
# $PROMPT += '{sysinfo}'    # Can be static, system_type and system_category can be set in the config file, /etc/sysinfo or ~/.sysinfo
$PROMPT += '{user}{at}{hostname} {curdir} '
$PROMPT += '{venv}{git}{rc}{bg}{stp}{tmux}{timed}'
$PROMPT += '{NO_COLOR}{prompt_end} '

# xontrib load coreutils distributed docker_tabcomplete mpl vox vox_tabcomplete click_tabcomplete fzf-widgets schedule avox
