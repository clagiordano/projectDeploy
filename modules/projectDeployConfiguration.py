#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  projectDeploy
#
#  Version 2.0
#
#  Copyright 2014 - 2015 Claudio Giordano <claudio.giordano@autistici.org>
#
#  License GPLv3 https://www.gnu.org/licenses/gpl.html

import sys
import os
import re
import tempfile

"""" Local import """
import outputUtils as out

""" 
Configuration class for ProjectDeploy
"""
class ProjectDeployConfiguration(object):
    def __init__(self):
        # Tempfile for rsync output and dialog configuration
        self.tempFile = tempfile.mkstemp()[1];
        self.dialogTempFile = tempfile.mkstemp()[1];

        # Script name configuration
        #~ scriptName = __file__
        self.scriptName = "projectDeploy"

        # Path configuration
        self.basePath = os.environ['HOME'] + "/." + self.scriptName
        self.logPath = self.basePath + "/" + self.scriptName + ".log"
        self.configPath = self.basePath + "/" + self.scriptName + ".conf"
        self.defaultProjectsRoot = "/tmp"

        # Projects file configurations with default value
        self.syncPreFile          = "pre-sync"
        self.syncPostFile         = "post-sync"
        self.syncIgnoresFile      = "ignores"
        self.syncTargetsFile      = "targets"
        self.syncMultiTargetsFile = "multitargets"
        self.syncExtraOptions     = "rsync-extra"
        
        # Switch configuration
        self.dialogMode               = False
        self.verboseMode              = False
        self.debugMode                = False
        self.multitargetMode          = False
        self.multitargetModeAvailable = False

        # Messages configurations
        self.dialogTitle = "Choose a project to deploy from"
        self.deployMsg = "Choose a project's number to deploy or 0 to abort: "
        self.deployAbortMsg = "Deploy aborted."
        self.deploySelectFromListMsg = "Select an element from list or 0 to abort: "

        # NOTE: Option info none only suppported from rsync protocol v.31
        # Classic output verbose with percentage progress for single file
        self.rsyncOptions = "-arvzhi --progress --delete"
        # Solo output avanzamento globale, %, velocità e stats finali al termine
        self.rsyncOptions = "-arzh --info=none,progress2,stats --delete"
        # Solo output avanzamento globale, % e velocità
        self.rsyncOptions = "-arzhvi --info=progress2 --delete"

        # Dialog config
        # Auto-size with height and width = 0. Maximize with height and width = -1.
        self.dialogType             = "menu"
        self.dialogMenuHeight       = 0
        self.dialogMenuWidth        = 0
        self.dialogMenuMenuHeight   = 0
        
        self.varConversion          = {}
        self.varConversion['PROJECT_ROOT'] = 'defaultProjectsRoot'
        self.varConversion['RSYNC_OPTIONS'] = 'rsyncOptions'
    
    def readConfigFile(self, filePath):
        
        """ Test config file"""
        try:
            #~ New config file
            cp = ConfigParser.ConfigParser()
            conf = cp.read(filePath);
            print "[Debug]: %s" % (conf)
            out.success("Found new config file")
        except:
            #~ Old config file
            fileContent = open(filePath, "r").readlines()
            out.warning("Found OLD config file")
            print "[Debug]: fileContent %s" % (fileContent)
            self.migrateOldConfigfile(fileContent)
            
        #~ try:
            #~ print("[Debug]: PRE test bash vars: %s" % (os.getenv['PROJECT_ROOT']))
            #~ print("[Debug]: PRE test bash vars: %s" % (os.environ['PROJECT_ROOT']))
        #~ except:
            #~ print "[Debug]: var not found"
            
        #~ fileContent = open(filePath, "r").read()
        #~ print "[Debug]: %s" % (fileContent)

    #~ def testConfigFile(self, filePath)

    def migrateOldConfigfile(self, optionsList):
        print "[Debug]: optionsList: %s" % (optionsList)
        for optionRow in optionsList:
            print "[Debug]: optionRow: %s" % (optionRow)
            matches = re.search("(?P<option>\w+)=(?P<value>.*)?", optionRow)
            if (matches):
                print "[Debug]: matches: %s" % (matches.groupdict())
                oldVar   = matches.groupdict()['option']
                oldValue = matches.groupdict()['value']
                
                print "[Debug]:   oldVar: %s" % (oldVar)
                print "[Debug]: oldValue: %s" % (oldValue)
                print "[Debug]: new var: %s" % (self.varConversion[oldVar])
