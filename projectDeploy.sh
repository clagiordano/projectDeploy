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
#IFS='
#';



# Configurations
DIALOG_MODE="false";
VERBOSE_MODE="false";
DEBUG_MODE="false";

DIALOG_TYPE="menu";
PROJECT_ROOT="/tmp"; #/usr/share/nginx/html/git/release;
DIALOG_TITLE="Choose a project to deploy from";
DEPLOY_MSG="Choose a project's number to deploy or 0 to abort: ";
DEPLOY_ABORT_MSG="Deploy aborted.";

DEPLOY_SELECT_FROM_LIST_MSG="Select an element from list or 0 to abort: ";

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
    echo -e "\t -b \t\t Enable debug mode.";
    echo;
}

function fatalError()
{
    echo "";
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

function debug()
{
    if [ ${DEBUG_MODE} == "true" ]
    then
        #echo -e "[\033[0;35mDEBUG\033[0m      ]: \033[0;35m$1\033[0m" 1>&2;  # Redirige lo stdout su stderr
        echo -e "\033[1;30m[DEBUG      ]: $1\033[0m" 1>&2;  # Redirige lo stdout su stderr
    fi
}


function parseArgs()
{
    while getopts ":dvtr:b" Options $*;
    do
        case ${Options} in
            d)
                DIALOG_MODE="true"
                echo "Enabled dialog mode";
            ;;

            v)
                VERBOSE_MODE="true"
                echo "Enabled verbose mode";
            ;;

            t)
                DIALOG_MODE="false"
                echo "Enabled text mode";
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

            b)
                DEBUG_MODE="true"
                echo "Enabled debug mode";
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
    declare -a PROJECT_LIST=();
    local index=0;
    for project in `ls -d ${PROJECT_ROOT}/*/`;
    do
        debug "${index}: ${project}";
        PROJECT_LIST[${index}]="${project}";
        let "index += 1";
    done;

    debug "PROJECT_LIST COUNT: ${#PROJECT_LIST[*]}";
    debug "PROJECT_LIST ARRAY: ${PROJECT_LIST[*]}";
    debug "  TEST SELECTION 7: '${PROJECT_LIST[7]}'";
    debug "";

    echo ${PROJECT_LIST[@]};
}

function printConfirm()
{
    debug "ARG1: '$1'";
    debug "ARG2: '$2'";
    debug "ARG3: '$3'";
    debug "ARG4: '$4'";

    if [[ ! -z $1 ]]
    then
        CONFIRM_QUESTION="$1";
    else
        CONFIRM_QUESTION="Confirm action? [y/N]";
    fi

    # Valid answer
    if [[ ! -z $2 ]]
    then
        CONFIRM_VALID_ANSWER="$2";
    else
        CONFIRM_VALID_ANSWER="y";
    fi

    #if [[ ! -z $3 ]]
    #then
    #    CONFIRM_PATTERN=$3; #[^[:digit:]]
    #else
        #matches alphabetic or numeric characters. This is equivalent to [A-Za-z0-9].
    #    CONFIRM_PATTERN="[^[:alnum:]]";
    #fi

    #if [[ ! -z $4 ]]
    if [[ ! -z $3 ]]
    then
        CONFIRM_ACTION="$3";
    else
        fatalError "Invalid confirm action, exit.";
    fi

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
        read -p "${CONFIRM_QUESTION}: " SELECTION

        # || ${SELECTION} == "n" || ${SELECTION} == "N"
        if [[ ${SELECTION} != "${CONFIRM_VALID_ANSWER}" ]]
        then
            warning "${DEPLOY_ABORT_MSG}";
            exit 0;
        else
            CHOOSED="true";
            CONFIRM="true";
            echo "";

            eval "${CONFIRM_ACTION}";
        fi
    done
}

function selectProject()
{
    local PROJECT_LIST=($*);

    CHOOSED="false";
    while [ ${CHOOSED} == "false" ]
    do
        read -p "${DEPLOY_MSG}" SELECTION

        if [[ ${SELECTION} == "0" ]]
        then
            warning "${DEPLOY_ABORT_MSG}";
            exit 0
        elif ! `echo ${SELECTION} | grep -q "[^[:digit:]]"` \
            && [[ ! -z ${SELECTION} ]] \
            && [[ ${SELECTION} -ge "0" ]] \
            && [[ ${SELECTION} -le "${#PROJECT_LIST[*]}" ]]
        then
            CHOOSED="true"
            debug "         SELECTION: ${SELECTION}";
            debug "          SELECTED: '${PROJECT_LIST[${SELECTION}]}'";

            let "SELECTION -= 1";
            SELECTED_PROJECT=`basename ${PROJECT_LIST[${SELECTION}]}`;
            if [ $? ]
            then
                success "Selected project '\033[1;32m${SELECTED_PROJECT}\033[0m'";
                checkConfigs "${SELECTED_PROJECT}";
            else
                fatalError "Invalid project name during selection. ${DEPLOY_ABORT_MSG}";
            fi
        else
            error "Invalid choice '\033[1;31m${SELECTION}\033[0m', please insert only a project's number.\n";
        fi
    done
}

function selectFromList()
{
    local LIST=($*);

    CHOOSED="false";
    while [ ${CHOOSED} == "false" ]
    do
        read -p "${DEPLOY_SELECT_FROM_LIST_MSG}" SELECTION

        if [[ ${SELECTION} == "0" ]]
        then
            warning "${DEPLOY_ABORT_MSG}";
            exit 0
        elif ! `echo ${SELECTION} | grep -q "[^[:digit:]]"` \
            && [[ ! -z ${SELECTION} ]] \
            && [[ ${SELECTION} -ge "0" ]] \
            && [[ ${SELECTION} -le "${#LIST[*]}" ]]
        then
            CHOOSED="true"
            debug "         SELECTION: ${SELECTION}";
            debug "          SELECTED: '${LIST[${SELECTION}]}'";

            let "SELECTION -= 1";
            SELECTED_ELEMENT="${LIST[${SELECTION}]}";
            if [ -n "${SELECTED_ELEMENT}" ]
            then
                success "Selected element '\033[1;32m${SELECTED_ELEMENT}\033[0m'";
            else
                fatalError "Error during selection. ${DEPLOY_ABORT_MSG}";
            fi
        else
            error "Invalid choice '\033[1;31m${SELECTION}\033[0m', please insert only the number corresponding to an element of the list.\n";
        fi
    done
}

function displayConfirm()
{
    dialog --yesno "${CONFIRM_QUESTION}" 10 40 2>${DIALOG_TEMP_FILE};

    if [ $? ]
    then
        CONFIRM="true";
    else
        warning "\n${DEPLOY_ABORT_MSG}";
        exit 0;
    fi
}

function startSync()
{
    debug "startSync: ARG1: '$1'";

    if [[ $1 -eq "dryrun" ]]  # Dry run?
    then
        debug "rsync ${RSYNC_OPTIONS} --dry-run ${RSYNC_IGNORE} ${PROJECT_ROOT}/${SELECTED_PROJECT}";
    else
        debug "rsync ${RSYNC_OPTIONS} ${RSYNC_IGNORE} ${PROJECT_ROOT}/${SELECTED_PROJECT}";
    fi;
    #rsync
}

function deploy()
{
    debug "deploy: ARG1: $1";

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
# ~/.[SCRIPT NAME]/[PROJECT NAME]/presync   (pre sync commands OPTIONAL)
# ~/.[SCRIPT NAME]/[PROJECT NAME]/postsync  (post sync commands OPTIONAL)
# ~/.[SCRIPT NAME]/[PROJECT NAME]/ignores   (file to exlude from sync OPTIONAL)
# ~/.[SCRIPT NAME]/[PROJECT NAME]/targets   (destination list in format: USER@HOST:PATH  REQUIRED)
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

    if [ ! -e "${CONFIG_DIR}/${SYNC_TARGETS_FILE}" ]
    then
        fatalError "No '\033[1;31m${SYNC_TARGETS_FILE}\033[0m' file found for this project.";
    else
        success "Found '${SYNC_TARGETS_FILE}' file for this project.";
    fi;

    # Check and set ignore file list
    RSYNC_IGNORE="";
    if [ -e "${CONFIG_DIR}/${SYNC_IGNORES_FILE}" ];
    then
        success "Found '${SYNC_IGNORES_FILE}' file. Including in rsync.";
        RSYNC_IGNORE="--exclude-from=${CONFIG_DIR}/${SYNC_IGNORES_FILE}";
    else
        success "No '${SYNC_IGNORES_FILE}' file found for this project.";
    fi;
}

function printList()
{
    debug "printList: ARGS *: $*";
    local LIST=($*);

    debug "           LIST COUNT: ${#LIST[*]}";
    debug "           LIST ARRAY: ${LIST[*]}";
    debug "  TEST SELECTION 7: '${LIST[7]}'";

    if  [[ ${DIALOG_MODE} == "false" ]]
    then
        drawTextList ${LIST[*]};
    else
        drawDialogMenu ${LIST[*]};
    fi
}

function drawTextList()
{
    #clear;
    echo -e "$DIALOG_TITLE [ \033[1;34m${PROJECT_ROOT}\033[0m ]:";

    local LIST=($*);
    local index=0

    debug "  TEST SELECTION 7: '${LIST[7]}'";

    for project in ${LIST[*]}
    do
        let "index += 1";
        printf "[\033[1;34m%4d\033[0m]: %s\n" "${index}" "${project}";
    done;
    echo "";
}

function drawDialogMenu()
{
    local LIST=($*);
    local index=0

    for project in ${LIST[*]}
    do
        let "index += 1";
        DIALOG_ITEMS="${DIALOG_ITEMS} ${index} \"${project}\" ";
    done;

    eval "dialog \"--${DIALOG_TYPE}\" \"${DIALOG_TITLE} [ ${PROJECT_ROOT} ]:\" ${DIALOGMENU_HEIGHT} \
        ${DIALOGMENU_WIDTH} ${DIALOGMENU_MENUHEIGHT} ${DIALOG_ITEMS} 2>${DIALOG_TEMP_FILE}";

    if [ $? ]
    then
        local SELECTION=`cat "${DIALOG_TEMP_FILE}"`;
        let "SELECTION -= 1";
        SELECTED_PROJECT=`basename ${LIST[${SELECTION}]}`;

        checkConfigs "${SELECTED_PROJECT}";
    else
        warning "${DEPLOY_ABORT_MSG}";
        exit 0;
    fi
}

function createDestinationList()
{
    # Check targets file list
    local LIST=();
    local INDEX=0;

    for target in `cat "${CONFIG_DIR}/${SYNC_TARGETS_FILE}"`
    do
        let "INDEX += 1";
        debug "target: ${target}";
        LIST[${INDEX}]=${target};
    done

    echo ${LIST[@]};
}

# Start script:
clear;

parseArgs $*;
printList `createProjectsList`;

if [[ ${DIALOG_MODE} == "false" ]]
then
    selectProject `createProjectsList`;
    echo "";
fi

#createDestinationList;
printList `createDestinationList`;
selectFromList `createDestinationList`;

printConfirm "Start simulation deploy? [y/N]" "y" "deploy \"dryrun\""; #\033[1;32m \033[0m
printConfirm "Start REAL deploy? [y/N]" "y" "deploy"; #\033[1;33m \033[0m


exit 0;
