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

# Configurations
IFS='
';

PROJECT_ROOT=/home/claudio/Dropbox/Progetti; #/usr/share/nginx/html/git/release;
PROJECT_LIST=();
DIALOG_TITLE="Choose a project to deploy: ";
DEPLOY_MSG="Choose a project's number to deploy or 0 to abort: ";

clear;

index=0;
echo $DIALOG_TITLE;
for project in ${PROJECT_ROOT}/*; 
do
    let "index += 1";
    PROJECT_LIST[$index]=$project/;
    echo "$index: $project";
done;
echo "";

#~ echo -e "Founded "${#PROJECT_LIST[*]}" projects";

#~ read -p "$DIALOG_TITLE" choice;
#~ while (( $choice >= ${#PROJECT_LIST[@]} || $choice < 0 )); do 
    #~ echo Invalid choice $choice;
    #~ read -p "$DIALOG_TITLE" choice;
#~ done;


while [[ $choice -ge "0" ]] && [[ $choice -le "${#PROJECT_LIST[*]}" ]]
do
    read -p $DEPLOY_MSG choice
    case $choice in
        y | yes | s | si )
            
        ;;

        0 )
            echo -e "\nDeploy aborted.";
            exit 0
        ;;

        * )
            echo -e "\nInvalid choice '$choice', please insert only a project's number.";
        ;;
    esac
done


exit 0;
