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
IFS='
';
DIALOG_MODE="false";
VERBOSE_MODE="false";
DIALOG_TYPE="menu";
PROJECT_ROOT="/tmp"; #/usr/share/nginx/html/git/release;
DIALOG_TITLE="Choose a project to deploy from";
DEPLOY_MSG="Choose a project's number to deploy or 0 to abort: ";
RSYNC_OPTIONS="-arvzh --progress --delete";
CONFIG_BASE_PATH="$HOME/.projectDeploy";
DIALOG_TEMP_FILE="/tmp/`basename ${0%.*}`";

DIALOGMENU_HEIGHT="30";
DIALOGMENU_WIDTH="70";
DIALOGMENU_MENUHEIGHT="30";
PROJECT_LIST=();

function Usage()
{
    echo -e "Usage: `basename $0` [ OPTIONS ]"
    echo -e "\t -g \t\t Enable dialog mode."
    echo -e "\t -v \t\t Verbose output."
    echo -e "\t -t \t\t Enable text mode."
    echo -e "\t -r \t\t Change projects root."
}

function error()
{
    echo -e "[\033[1;31mERROR\033[0m]: $1";
    exit 1;
}

function parseArgs()
{
    ARGS=$(getopt -o dvtr: -l "dialog,verbose,text,root:" -n "projectDeploy" -- "$@");
    echo "parseArgs: $ARGS ($@)";
    if [ $? -ne 0 ];
    then
        echo -e "Impossibile comprendere il comando impartito"
        exit 1
    fi

    eval set -- "${ARGS}";

    while true;
    do
        case "$1" in
            -g|--dialog)
                shift
                DIALOG_MODE="true"
                echo "selected dialog mode";
                ;;

            -v|--verbose)
                shift
                VERBOSE_MODE="true"
                echo "selected verbose mode";
                ;;

            -t|--text)
                shift
                DIALOG_MODE="false"
                echo "selected text mode";
                ;;

            -r|--root)
                shift
                if [ -n "$1" ];
                then
                    PROJECT_ROOT="$1"
                    echo "override root: $PROJECT_ROOT";
                    shift
                fi
                ;;

            --)
                shift
                break
            ;;
        esac
    done
}

function parseArgsOld()
{
    while getopts "dvtr:" Options $*
    do
      case ${Options} in
        d)
            DIALOG_MODE="true"
            echo "selected dialog mode";
        ;;

        v)
            VERBOSE_MODE="true"
            echo "selected verbose mode";
        ;;

        t)
            DIALOG_MODE="false"
            echo "selected text mode";
        ;;

        r)
            if [[ $OPTARG =~ "^-.*" ]]
            then
                echo "Missing required argument to the -r parameter, exit.";
                Usage
                exit 1
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
                    error "Invalid path '${OPTARG}'";
                    exit 1;
                fi
            fi
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
}

function checkConfigs()
{
    CONFIG_DIR=$1;
    echo "proj: '$CONFIG_BASE_PATH/$CONFIG_DIR'";
    if [ ! -e "$CONFIG_BASE_PATH/$CONFIG_DIR" ]
    then
        echo "la cartella non esiste la creo";
        eval "mkdir -p \"$CONFIG_BASE_PATH/$CONFIG_DIR\"";
    else
        echo "la cartella esiste, leggo il contenuto";
        #read config
        #check cartella configurazione progetto
        #verifica se esistono i file
        echo "";
    fi

}

function printProjectsList()
{
    if  [[ ${DIALOG_MODE} == "false" ]]
    then
        drawTextList;
    else
        drawDialogMenu;
    fi
    echo "";
}

function drawTextList()
{
    clear;
    echo -e "$DIALOG_TITLE [ \033[1;34m${PROJECT_ROOT}\033[0m ]:";

    local index=0
    for project in ${PROJECT_LIST[@]}
    do
        let "index += 1";
        printf "[\033[1;34m%4d\033[0m]: %s\n" "${index}" "${project}";
    done;

    echo "";

    CHOOSED="false";
    while [ ${CHOOSED} == "false" ]
    do
        read -p ${DEPLOY_MSG} choice

        if [[ ${choice} == "0" ]]
        then
            echo -e "\nDeploy aborted.";
            exit 0
        elif ! `echo ${choice} | grep -q [^[:digit:]]` \
            && [[ ! -z ${choice} ]] \
            && [[ ${choice} -ge "0" ]] \
            && [[ ${choice} -le "${#PROJECT_LIST[*]}" ]]
        then
                CHOOSED="true"
                SELECTED_PROJECT=`basename ${PROJECT_LIST[${choice}]}`;
                echo -e "Selected project '\033[1;32m${SELECTED_PROJECT}\033[0m'";
                checkConfigs ${SELECTED_PROJECT};
        else
            echo -e "\nInvalid choice '\033[1;31m$choice\033[0m', please insert only a project's number.\n";
        fi
    done
}

function drawDialogMenu()
{
    local index=0
    for project in ${PROJECT_LIST[@]}
    do
        let "index += 1";
        DIALOG_ITEMS="${DIALOG_ITEMS} ${index} ${project} ";
    done;

    eval "dialog \"--${DIALOG_TYPE}\" \"${DIALOG_TITLE} [ ${PROJECT_ROOT} ]:\" ${DIALOGMENU_HEIGHT} \
        ${DIALOGMENU_WIDTH} ${DIALOGMENU_MENUHEIGHT} ${DIALOG_ITEMS} 2>${DIALOG_TEMP_FILE}";

    #checkConfigs $SELECTED_PROJECT
}

# Start script:
parseArgsOld $@
createProjectsList;
printProjectsList;

exit 0;
