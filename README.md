# Description

project Deploy is general purpose tool for project deployment over rsync with
specific config for project, configurable ignores, list of selectable targets,
list of multi target for massively deploy, entry point for pre and post deploy
for arbitrary command execution and related exit status.
Allow global config file and/or the use of command line switch/args for override configs.

# Notes about versions
* Until version 1.5 projectDeploy is a shell (bash) script
* From version 2.0 (WIP) the shell (bash) code was migrated to python to improve features

# Requirements
- python >= 2.6

# Features
- general purpose deployment tool
- specific config for project
- configurable ignores
- list of selectable targets
- support for multi targets deploy
- entry point for pre and post deploy for arbitrary command execution

# Installation
```bash
git clone https://github.com/clagiordano/projectDeploy.git

echo 'export PATH=$PATH:/path/to/projectDeploy' >> ~/.bashrc
```

# Update
Easily pull changes from repository with git command
```bash
git pull
```

# Configuration

## Minimum required configurations
To work properly projectDeploy need this config files into .projectDeploy/projectName folder

* ~/.projectDeploy/[PROJECT NAME]/targets *(destinations list)*

## Optional configurations files
You can also specificate this optional configuration files if need a default behavior or need to execute commands or script into pre and/or post deploy operation

* ~/.projectDeploy/projectDeploy.conf *(global config file)*
* ~/.projectDeploy/[PROJECT NAME]/presync *(pre sync commands)*
* ~/.projectDeploy/[PROJECT NAME]/postsync *(post sync commands)*
* ~/.projectDeploy/[PROJECT NAME]/ignores *(file to exlude from sync)*
* ~/.projectDeploy/[PROJECT NAME]/multitargets *(multi destination list)*

### Target / multitargets file formats
Targets must be defined one for line as:

- USER@HOST:PATH
- USER@HOST2:PATH

# Workflow

## Common steps
- list projects directory
- select project
- list targets
- select targets
- select single or multi target

## Single deploy project
- call presync
- simulation deploy
- deploy
- call post sync

## Multi deploy project
- call presync
- simulation deploy to all targets
- deploy to all targets
- call post sync

# TODO
- rsync progess during deploy / simulation
- pass addictional params to pre / post sync script from main script by CLI
- logging deploy

# License
projectDeploy is released under the GNU LGPL-3.0 license

Copyright (C) 2016 Claudio Giordano <claudio.giordano@autistici.org>
