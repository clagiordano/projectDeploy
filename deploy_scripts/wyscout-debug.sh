#!/bin/sh

#su apache -s /bin/sh

preview_cmd="rsync -cvzhrltgoD --delete"
sync_cmd="rsync -cvzhrltgoD --delete"


project_root=/usr/share/nginx/html/git;
user_dirs=/usr/share/nginx/html/users;
projects=();

echo "Choose a project to deploy:";
i=-1;
for project in ${project_root}/*/*; do
	i=$(( i+1 ));
	projects[$i]=$project/;
	echo "$i. $project";
done;

for project in ${user_dirs}/*/*; do
	i=$(( i+1 ));
	projects[$i]=$project/;
	echo "$i. $project";
done;


read choice;
while (( $choice >= ${#projects[@]} || $choice < 0 )); do 
	echo Invalid choice $choice;
	read choice;
done;

project=${projects[$choice]};
configDir=`pwd`/`basename $project`;

if [[ -e $configDir/sync-target ]]; then
	destinations=();
	echo "Choose a destination:";
	i=-1;
	for destination in `cat $configDir/debug-target`; do
		i=$(( i+1 ));
		destinations[$i]=$destination;
		echo "$i. $destination";
	done;
	
	read choice;
	while (( $choice >= ${#destinations[@]} || $choice < 0 )); do 
		echo Invalid choice $choice;
		read choice;
	done;
	
	destination=${destinations[$choice]};
else
	echo "Enter a destination:";
	read destination;
fi;

ignoreFile="";
if [[ -e $configDir/sync-ignore ]]; then 
	echo "\nFound sync-ignore file. Including in rsync."; 
	ignoreFile="--exclude-from=$configDir/sync-ignore";
else
	echo "\nNo sync-ignore file found for this project.";
fi;

$preview_cmd $ignoreFile $project $destination;

echo "Do you want to deploy? [y/N]";
read confirmation

if [[ $confirmation != "y" ]]; then
	exit;
fi;

if [[ -x $configDir/pre-sync ]]; then
	echo "Executing pre-sync hook. This may affect the sync preview."
        (cd $project; $configDir/pre-sync)
fi;


$sync_cmd $ignoreFile $project $destination;

