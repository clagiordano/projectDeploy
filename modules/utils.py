#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import subprocess
import shlex
import socket
import modules.outputUtils as out

def getSessionInfo():
    info = {}
    output = runShellCommand("who am i")[0].split('\n')[1].split(' ')
    info['username'] = os.getlogin()
    info['ipaddress'] = output[-1][1:-1]

    info['hostname'] = socket.gethostname()
    if info['ipaddress'] != ":0":
        info['hostname'] = socket.gethostbyaddr(info['ipaddress'])

    return info

def runShellCommand(command):
    try:
        p = subprocess.Popen(\
            shlex.split(command), \
            shell=True, \
            stdin=subprocess.PIPE, \
            stdout=subprocess.PIPE, \
            stderr=subprocess.PIPE)
        command_output, command_error = p.communicate()
        exit_status = p.returncode
    except:
        out.fatalError("Failed to execute command " + command)

    return command_output, exit_status, command_error
