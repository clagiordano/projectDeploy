#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import subprocess
import shlex
import socket
import modules.outputUtils as out

def getSessionInfo():
    info = {}
    output = subprocess.Popen(["who", "am", "i"], stdout=subprocess.PIPE).communicate()
    output = output[0].strip().split(' ')
    info['username'] = os.getlogin()
    info['ipaddress'] = output[-1][1:-1]

    info['hostname'] = socket.gethostname()
    if info['ipaddress'] != ":0":
        try:
            info['hostname'] = socket.gethostbyaddr(info['ipaddress'])
        except:
            try:
                info['hostname'] = getNetbiosHostname(info['ipaddress'])
            except:
                info['hostname'] = info['ipaddress']

    return info

def getNetbiosHostname(ipaddress):
    output = runShellCommand("nmblookup -A " + ipaddress, False)

    return output[0].split('\n')[1].split(' ')[0].strip()

def runShellCommand(command, shell=True):
    try:
        p = subprocess.Popen( \
            shlex.split(command), \
            shell=shell, \
            stdin=subprocess.PIPE, \
            stdout=subprocess.PIPE, \
            stderr=subprocess.PIPE)
        command_output, command_error = p.communicate()
        exit_status = p.returncode
    except:
        out.fatalError("Failed to execute command " + command)

    return command_output, exit_status, command_error
