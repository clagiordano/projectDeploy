#!/bin/bash

for dir in $(ls -d */); 
do
    echo "updating dir $dir"; 
    cd "$dir";
    if [ -d ".git" ]
    then
        git pull;
    else
        echo "not a git repository, skip";
    fi
    cd ..;
done
