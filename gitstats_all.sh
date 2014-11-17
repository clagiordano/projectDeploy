#!/bin/bash

for dir in $(ls -d */); 
do 
	echo "generating stats for project $dir"; 
	gitstats "$dir" /var/www/html/stats/$dir; 
done
