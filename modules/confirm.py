#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""This script prompts a user to confirm an action"""
#  outputUtils
#
#  Copyright 2014 - 2015 Claudio Giordano <claudio.giordano@autistici.org>
#
#  License GPLv3 https://www.gnu.org/licenses/gpl.html

"""Prompts a question to user and if valid answer is selected,
returns true otherwise returns false"""
def getConfirm(inputMessage="Confirm action? [y/N]", validAnswer="y"):
    choosed = False
    answer = False
    print ""
    while choosed is False:
        selection = raw_input(inputMessage + " ")
        if selection == validAnswer:
            answer = True
        choosed = True

    return answer
