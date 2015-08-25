# projectDeploy

project Deploy is a tool for project deployment over rsync with specific config for project,
configurable ignores, list of selectable targets, list of multi target for massively deploy, 
pre/post sync commands and validation status of all commands.
Allow global config file and/or the use of command line switch/args for override configs.

*Copyright (C) 2015 Claudio Giordano <claudio.giordano@autistici.org>*

## Version notes
* Until version 1.5 projectDeploy is a shell (bash) script
* "From version 2.0 (WIP) the shell (bash) code was migrated to python to improve features"

#### Valid config files:

* ~/.[SCRIPT NAME]/[SCRIPT NAME].conf           (global config file OPTIONAL)
* ~/.[SCRIPT NAME]/[PROJECT NAME]/presync       (pre sync commands OPTIONAL)
* ~/.[SCRIPT NAME]/[PROJECT NAME]/postsync      (post sync commands OPTIONAL)
* ~/.[SCRIPT NAME]/[PROJECT NAME]/ignores       (file to exlude from sync OPTIONAL)
* ~/.[SCRIPT NAME]/[PROJECT NAME]/targets       (destination list in format: USER@HOST:PATH  REQUIRED)
* ~/.[SCRIPT NAME]/[PROJECT NAME]/multitargets  (multi destination list in format: USER@HOST:PATH  OPTIONAL)
