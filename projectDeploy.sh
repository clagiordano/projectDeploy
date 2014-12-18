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
#
#

clear;

# Configurations
IFS='
';
DIALOG_MODE="false";
VERBOSE_MODE="false";
PROJECT_ROOT=/tmp; #/usr/share/nginx/html/git/release;
DIALOG_TITLE="Choose a project to deploy: ";
DEPLOY_MSG="Choose a project's number to deploy or 0 to abort: ";
RSYNC_OPTIONS="-arvzh --progress --delete";
CONFIG_BASE_PATH="~/.projectDeploy"


# Parser args
while getopts "gvt" Options
do
    # Check Args:

  case $Options in
        g)
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

    esac
done
shift $(($OPTIND - 1))

function printProjectsList()
{
    clear;

    PROJECT_LIST=();
    index=0;

    echo -e "$DIALOG_TITLE\n";
    for project in ${PROJECT_ROOT}/*;
    do
        let "index += 1";
        PROJECT_LIST[$index]=$project/;
        echo "$index $project";
    done;
    echo "";
}

function readConfigs()
{
    CONFIG_DIR=$1;
    echo "proj: $CONFIG_BASE_PATH/$CONFIG_DIR";
}

printProjectsList;

CHOOSED="false";
while [ $CHOOSED == "false" ]
do
    read -p $DEPLOY_MSG choice

    if [[ $choice == "0" ]]
    then
        echo -e "\nDeploy aborted.";
        exit 0
    elif ! `echo $choice | grep -q [^[:digit:]]` \
        && [[ ! -z $choice ]] \
        && [[ $choice -ge "0" ]] \
        && [[ $choice -le "${#PROJECT_LIST[*]}" ]]
    then
            CHOOSED="true"
            #~ configDir=`pwd`/`basename $project`;
            SELECTED_PROJECT=`basename ${PROJECT_LIST[$choice]}`;
            echo -e "Selected project '\033[1;32m$SELECTED_PROJECT\033[0m'";

            readConfigs $SELECTED_PROJECT;
    else
        echo -e "\nInvalid choice '\033[1;31m$choice\033[0m', please insert only a project's number.\n";
    fi
done



exit 0;
