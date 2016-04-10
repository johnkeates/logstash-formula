# -*- coding: utf-8 -*-
'''
Module to provide Logstash compatibility to Salt.
Todo: A lot.
'''
from __future__ import absolute_import

# Import salt libs
import salt.utils

# Import python libs
import logging
import random
import string
from salt.ext.six.moves import range

log = logging.getLogger(__name__)


def __virtual__():
    '''
    Verify Logstash is installed.
    '''
    return salt.utils.which('/opt/logstash/bin/logstash-plugin') is not None


def _format_response(response, msg):
    if isinstance(response, dict):
        if response['retcode'] != 0:
            msg = 'Error'
        else:
            msg = response['stdout']
    else:
        if 'Error' in response:
            msg = 'Error'
    return {
        msg: response
    }


def _get_logstash_plugin():
    '''
    Returns the logstash-plugin command path if we're running an OS that
    doesn't put it in the standard /usr/bin or /usr/local/bin.
    '''
    logstash = salt.utils.which('/opt/logstash/bin/logstash-plugin')

    if logstash is None:
        logstash = False

    return logstash


def _strip_listing_to_done(output_list):
    '''Conditionally remove non-relevant first and last line,
    "Listing ..." - "...done".
    outputlist: logstash command output split by newline
    return value: list, conditionally modified, may be empty.
    '''

    # conditionally remove non-relevant first line
    f_line = ''.join(output_list[:1])
    if f_line.startswith('Listing') and f_line.endswith('...'):
        output_list.pop(0)

    # some versions of logstash have no trailing '...done' line,
    # which some versions do not output.
    l_line = ''.join(output_list[-1:])
    if '...done' in l_line:
        output_list.pop()

    return output_list


def _output_to_dict(cmdoutput, values_mapper=None):
    '''Convert logstash-plugin output to a dict of data
    cmdoutput: string output of logstash-plugin commands
    values_mapper: function object to process the values part of each line
    '''
    ret = {}
    if values_mapper is None:
        values_mapper = lambda string: string.split('\t')

    # remove first and last line: Listing ... - ...done
    data_rows = _strip_listing_to_done(cmdoutput.splitlines())

    for row in data_rows:
        key, values = row.split('\t', 1)
        ret[key] = values_mapper(values)
    return ret


def set_permissions(vhost, user, conf='.*', write='.*', read='.*', runas=None):
    '''
    Sets permissions for vhost via logstash-plugin set_permissions

    CLI Example:

    .. code-block:: bash

        salt '*' logstash.set_permissions 'myvhost' 'myuser'
    '''
    if runas is None:
        runas = salt.utils.get_user()
    res = __salt__['cmd.run'](
        'logstash-plugin set_permissions -p {0} {1} "{2}" "{3}" "{4}"'.format(
            vhost, user, conf, write, read),
        python_shell=False,
        runas=runas)
    msg = 'Permissions Set'
    return _format_response(res, msg)


def status(runas=None):
    '''
    return logstash status

    CLI Example:

    .. code-block:: bash

        salt '*' logstash.status
    '''
    if runas is None:
        runas = salt.utils.get_user()
    res = __salt__['cmd.run'](
        'logstash-plugin status',
        runas=runas
    )
    return res


def plugin_is_installed(name, runas=None):
    '''
    Return whether the plugin is enabled.

    CLI Example:

    .. code-block:: bash

        salt '*' logstash.plugin_is_installed foo
    '''
    logstash = _get_logstash_plugin()
    cmd = '{0} list -m -e'.format(logstash)
    if runas is None:
        runas = salt.utils.get_user()
    ret = __salt__['cmd.run'](cmd, python_shell=False, runas=runas)
    return bool(name in ret)


def install_plugin(name, runas=None):
    '''
    Enable a Logstash plugin via the logstash-plugins command.

    CLI Example:

    .. code-block:: bash

        salt '*' logstash.install_plugin foo
    '''
    logstash = _get_logstash_plugin()
    cmd = '{0} enable {1}'.format(logstash, name)

    if runas is None:
        runas = salt.utils.get_user()
    ret = __salt__['cmd.run_all'](cmd, python_shell=False, runas=runas)

    return _format_response(ret, 'Installed')


def uninstall_plugin(name, runas=None):
    '''
    uninstall a logstash plugin via the logstash-plugins command.

    CLI Example:

    .. code-block:: bash

        salt '*' logstash.uninstall_plugin foo
    '''

    logstash = _get_logstash_plugin()
    cmd = '{0} uninstall {1}'.format(logstash, name)

    if runas is None:
        runas = salt.utils.get_user()
    ret = __salt__['cmd.run_all'](cmd, python_shell=False, runas=runas)

    return _format_response(ret, 'Uninstalled')
