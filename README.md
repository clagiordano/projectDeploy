# gitScripts

*Copyright (C) 2015 Claudio Giordano*

## Summary

gitScripts is a collection of utility scripts varies for git and beyond.

## Features

### projectUpdate


### projectDeploy

project Deploy is a tool for project deployment over rsync with specific config for project,
configurable ignores, list of selectable targets, list of multi target for massively deploy, pre/post sync commands and validation status of all commands.
Allow global config file and/or the use of command line switch/args for override configs.

#### Valid config files:

* ~/.[SCRIPT NAME]/[SCRIPT NAME].conf           (global config file OPTIONAL)
* ~/.[SCRIPT NAME]/[PROJECT NAME]/presync       (pre sync commands OPTIONAL)
* ~/.[SCRIPT NAME]/[PROJECT NAME]/postsync      (post sync commands OPTIONAL)
* ~/.[SCRIPT NAME]/[PROJECT NAME]/ignores       (file to exlude from sync OPTIONAL)
* ~/.[SCRIPT NAME]/[PROJECT NAME]/targets       (destination list in format: USER@HOST:PATH  REQUIRED)
* ~/.[SCRIPT NAME]/[PROJECT NAME]/multitargets  (multi destination list in format: USER@HOST:PATH  OPTIONAL)

## Other utilities

### git-author-rewrite.sh
### gitStats_all.sh
### pull_all.sh
