import os
import psutil


def login_process():
    """
    Top most project that is not a terminal..

    local-osx: ('login', 'Terminal')
    remote-ssh: ('bash', 'sshd')
    """

    current_proc = psutil.Process(os.getpid())

    for _ in range(15):  # Don't bother looking further...
        parent = current_proc.parent()
        if parent.terminal():
            current_proc = parent
            continue

        return current_proc.name(), parent.name()

    return 'unknown'


def human_readable_time(seconds):
    m, s = divmod(seconds, 60)
    h, m = divmod(m, 60)
    d, h = divmod(h, 24)

    result = ''

    if d > 0:
        result += f'{d}d,'
    if h > 0:
        result += f'{h}h,'
    if m > 0:
        result += f'{m}m,'
    result += f'{s}s'

    return result


print(login_process())
