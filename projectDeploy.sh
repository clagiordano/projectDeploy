#!/bin/bash
#
#  projectDeploy.sh
#
#  Copyright 2014 Claudio Giordano <claudio.giordano@autistici.org>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.

#~ clear;

# Configurations
#IFS='
#';
DIALOG_MODE="false";
VERBOSE_MODE="false";
DIALOG_TYPE="menu";
PROJECT_ROOT="/tmp"; #/usr/share/nginx/html/git/release;
DIALOG_TITLE="Choose a project to deploy from";
DEPLOY_MSG="Choose a project's number to deploy or 0 to abort: ";
DEPLOY_ABORT_MSG="Deploy aborted.";
RSYNC_OPTIONS="-arvzh --progress --delete";
CONFIG_BASE_PATH="$HOME/.projectDeploy";
DIALOG_TEMP_FILE="/tmp/`basename ${0%.*}`";

# Auto-size with height and width = 0. Maximize with height and width = -1.
DIALOGMENU_HEIGHT="0";
DIALOGMENU_WIDTH="0";
DIALOGMENU_MENUHEIGHT="0";
LIST=();

SYNC_PRE_FILE="pre-sync";
SYNC_POST_FILE="post-sync";
SYNC_IGNORES_FILE="ignores";
SYNC_TARGETS_FILE="targets";

function Usage()
{
    echo -e "Usage: `basename $0` [ OPTIONS ]";
    echo -e "\t -d \t\t Enable dialog mode.";
    echo -e "\t -v \t\t Verbose output.";
    echo -e "\t -t \t\t Enable text mode.";
    echo -e "\t -r PATH\t Change projects root.";
    echo -e "\t -h \t\t Print this help.";
    echo;
}

function fatalError()
{
    echo -e "[\033[1;31mFATAL ERROR\033[0m]: $1\n";
    exit 1;
}

function error()
{
    echo -e "[\033[1;31mERROR\033[0m      ]: $1";
}

function success()
{
    echo -e "[\033[1;32mSUCCESS\033[0m    ]: $1";
}

function warning()
{
    echo -e "[\033[1;33mWARNING\033[0m    ]: $1";
}

function parseArgs()
{
    while getopts ":dvtr:" Options $*;
    do
        case ${Options} in
            d)
                DIALOG_MODE="true"
                echo "Selected dialog mode";
            ;;

            v)
                VERBOSE_MODE="true"
                echo "Selected verbose mode";
            ;;

            t)
                DIALOG_MODE="false"
                echo "Selected text mode";
            ;;

            r)
                if [[ "${OPTARG}" =~ "^-.*" ]]
                then
                    Usage;
                    fatalError "Missing required argument to the -${OPTARG} parameter.";
                else
                    if [ -d $OPTARG ]
                    then
                        if [ ${OPTARG:0:1} != "/" ]
                        then
                            PROJECT_ROOT=$OPTARG;
                        else
                            PROJECT_ROOT=${OPTARG%?};
                        fi
                    else
                        fatalError "Invalid path '\033[1;31m${OPTARG}\033[0m'";
                    fi
                fi
            ;;

            h)
                Usage;
                exit 0;
            ;;

            \?)
                Usage;
                fatalError "Invalid option '${OPTARG}'.";
            ;;

            :)
                Usage;
                fatalError "Missing required argument to the -${OPTARG} parameter.";
            ;;
        esac
    done
    shift $(($OPTIND - 1))
}

function createProjectsList()
{
    local index=0;
    for project in `ls -d ${PROJECT_ROOT}/*/`;
    do
        let "index += 1";
        PROJECT_LIST[$index]=${project};
    done;

    echo ${PROJECT_LIST[@]};
}


function printConfirm()
{
    CONFIRM_QUESTION=$1;

    if  [[ ${DIALOG_MODE} == "false" ]]
    then
        readConfirm;
    else
        displayConfirm;
    fi
}

function readConfirm()
{
    local CHOOSED="false";
    while [ ${CHOOSED} == "false" ]
    do
        read -p "${CONFIRM_QUESTION} [y/N]: " choice

        if [[ ${choice} != "y" ]]
        then
            echo -e "\n${DEPLOY_ABORT_MSG}";
            exit 0;
        else
            CHOOSED="true";
            CONFIRM="true";
            echo "";
        fi
    done
}

function displayConfirm()
{
    dialog --yesno "${CONFIRM_QUESTION}" 10 40 2>${DIALOG_TEMP_FILE};

    if [ "$?" = "0" ]
    then
        CONFIRM="true";
    else
        echo -e "\n${DEPLOY_ABORT_MSG}";
        exit 0;
    fi
}

function startSync()
{
    echo "ARG: '$1'";
    if [[ $1 -eq "dryrun" ]]  # Dry run?
    then
        echo "rsync ${RSYNC_OPTIONS} --dry-run ${RSYNC_IGNORE} ${PROJECT_ROOT}/${SELECTED_PROJECT}";
    else
        echo "rsync ${RSYNC_OPTIONS} ${RSYNC_IGNORE} ${PROJECT_ROOT}/${SELECTED_PROJECT}";
    fi;
    #rsync
}

function deploy()
{
    if [[ $1 -eq "dryrun" ]]  # Dry run?
    then
        #RSYNC_OPTIONS=${RSYNC_OPTIONS}" --dry-run";
        startSync "dryrun";
    else
        # Check and execute pre sync script
        if [[ -e "${CONFIG_DIR}/${SYNC_PRE_FILE}" ]];
        then
            echo "Executing pre-sync hook.";
            chmod +x "${CONFIG_DIR}/${SYNC_PRE_FILE}";
            "${CONFIG_DIR}/${SYNC_PRE_FILE}";

            if [ ! $? ]
            then
                fatalError "${SYNC_PRE_FILE} execution error!";
            fi
        fi;

        startSync;

        # Check and execute post sync script
        if [[ -e "${CONFIG_DIR}/${SYNC_POST_FILE}" ]];
        then
            echo "Executing post-sync hook.";
            chmod +x "${CONFIG_DIR}/${SYNC_POST_FILE}";
            "${CONFIG_DIR}/${SYNC_POST_FILE}";

            if [ ! $? ]
            then
                fatalError "${SYNC_POST_FILE} execution error!";
            fi
        fi;
    fi;
}

# Valid config files:
# ~/.[SCRIPT NAME]/[PROJECT NAME]/presync   (pre sync commands)
# ~/.[SCRIPT NAME]/[PROJECT NAME]/postsync  (post sync commands)
# ~/.[SCRIPT NAME]/[PROJECT NAME]/ignores   (file to exlude from sync)
# ~/.[SCRIPT NAME]/[PROJECT NAME]/targets   (destination list in format: USER@HOST:PATH)
# SYNC_PRE_FILE="pre-sync";
# SYNC_POST_FILE="post-sync";
# SYNC_IGNORES_FILE="ignores";
# SYNC_TARGETS_FILE="targets";
function checkConfigs()
{
    local PROJECT_NAME=$1;
    CONFIG_DIR="${CONFIG_BASE_PATH}/${PROJECT_NAME}";

    #echo "DEBUG: Project config dir: '${CONFIG_DIR}'";
    if [ ! -e "${CONFIG_DIR}" ]
    then
        #echo "DEBUG: la cartella non esiste la creo";
        mkdir -p "${CONFIG_DIR}"
    fi

    # Check and set ignore file list
    RSYNC_IGNORE="";
    if [[ -e "${CONFIG_DIR}/${SYNC_IGNORES_FILE}" ]];
    then
        echo -e "\nFound ${SYNC_IGNORES_FILE} file. Including in rsync.";
        RSYNC_IGNORE="--exclude-from=${CONFIG_DIR}/${SYNC_IGNORES_FILE}";
    else
        echo -e "\nNo ${SYNC_IGNORES_FILE} file found for this project.";
    fi;
}

function printList()
{
    local LIST=$@;
    if  [[ ${DIALOG_MODE} == "false" ]]
    then
        drawTextList ${LIST[@]};
    else
        drawDialogMenu ${LIST[@]};
    fi
    echo "";
}

function drawTextList()
{
    #clear;
    echo -e "$DIALOG_TITLE [ \033[1;34m${PROJECT_ROOT}\033[0m ]:";

    local LIST=$@;
    local index=0
    for project in ${LIST[@]}
    do
        let "index += 1";
        printf "[\033[1;34m%4d\033[0m]: %s\n" "${index}" "${project}";
    done;

    echo "";

    CHOOSED="false";
    while [ ${CHOOSED} == "false" ]
    do
        read -p "${DEPLOY_MSG}" choice

        if [[ ${choice} == "0" ]]
        then
            echo -e "\n${DEPLOY_ABORT_MSG}";
            exit 0
        elif ! `echo ${choice} | grep -q [^[:digit:]]` \
            && [[ ! -z ${choice} ]] \
            && [[ ${choice} -ge "0" ]] \
            && [[ ${choice} -le "${#LIST[*]}" ]]
        then
            CHOOSED="true"
            warning "${LIST[ ${choice} ]}";
            SELECTED_PROJECT=`basename ${LIST[ ${choice} ]}`;
            success "Selected project '\033[1;32m${SELECTED_PROJECT}\033[0m'";
            checkConfigs "${SELECTED_PROJECT}";
        else
            echo -e "\nInvalid choice '\033[1;31m$choice\033[0m', please insert only a project's number.\n";
        fi
    done
}

function drawDialogMenu()
{
    local index=0
    for project in ${LIST[@]}
    do
        let "index += 1";
        DIALOG_ITEMS="${DIALOG_ITEMS} ${index} \"${project}\" ";
    done;

    eval "dialog \"--${DIALOG_TYPE}\" \"${DIALOG_TITLE} [ ${PROJECT_ROOT} ]:\" ${DIALOGMENU_HEIGHT} \
        ${DIALOGMENU_WIDTH} ${DIALOGMENU_MENUHEIGHT} ${DIALOG_ITEMS} 2>${DIALOG_TEMP_FILE}";

    if [ "$?" = "0" ]
    then
        local SELECTION=`cat "${DIALOG_TEMP_FILE}"`;
        SELECTED_PROJECT=`basename ${LIST[${SELECTION}]}`;

        checkConfigs "${SELECTED_PROJECT}";
    else
        echo -e "\n${DEPLOY_ABORT_MSG}";
        exit 0;
    fi
}

function selectDestination()
{
    # Check targets file list
    local LIST=();
    index=0;
    for target in `cat "${CONFIG_DIR}/${SYNC_TARGETS_FILE}"`
    do
        let "index += 1";
        warning "target: ${target}";
        LIST[${index}]=${target};
    done

    echo ${AAA[@]};
}

# Start script:
clear;
parseArgs $@;
printList `createProjectsList`;
#printList `selectDestination`;
deploy "dryrun";
deploy

exit 0;
