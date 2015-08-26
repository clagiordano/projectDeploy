#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  outputUtils
#  
#  Copyright 2014 - 2015 Claudio Giordano <claudio.giordano@autistici.org>
#
#  License GPLv3 https://www.gnu.org/licenses/gpl.html

import sys

def fatalError(message):
    print "[\033[1;31mFATAL ERROR\033[0m]: %s" % (message)
    sys.exit(1)
    
def error(message):
    print "[\033[1;31mERROR\033[0m      ]: %s" % (message)
    
def success(message):
    print "[\033[1;32mSUCCESS\033[0m    ]: %s" % (message)
    
def warning(message):
    print "[\033[1;33mWARNING\033[0m    ]: %s" % (message)
    
def debug(message, debugMode = False):
    if (debugMode == True):
        print "\033[1;30m[DEBUG      ]: %s\033[0m" % (message)

"""
Write a message to logfile
"""
def log2file(message):
    pass
