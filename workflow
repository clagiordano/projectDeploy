# Start script:
init $*;

echo "";
printList `createProjectsList`;

if [[ ${DIALOG_MODE} == "false" ]]
then
    selectProject `createProjectsList`;
    echo "";
fi

# Se non ho eseguito l'override da argomento o configurazione chiede conferma
# ma solo se supportato dal progetto scelto
if [[ "${MULTITARGET_MODE}" == "false"
    && "${MULTITARGET_MODE_AVAILABLE}" == "true" ]]
then
    printConfirm "Enable multi target mode for this project? [y/N]" "y" "MULTITARGET_MODE=\"true\"" "false";
    echo "";
fi

if [[ ${MULTITARGET_MODE} == "false" ]]
then
    #createDestinationList;
    printList `createDestinationList`;
    selectFromList `createDestinationList`;

    printConfirm "Start simulation deploy? [y/N]" "y" "deploy ${SELECTED_ELEMENT} \"dryrun\""; #\033[1;32m \033[0m
    printConfirm "Start REAL deploy? [y/N]" "y" "deploy ${SELECTED_ELEMENT}"; #\033[1;33m \033[0m
else
    if [[ "${MULTITARGET_MODE_AVAILABLE}" == "false" ]]
    then
        fatalError "Multitarget unsupported for selected project";
    else
        printConfirm "Start simulation multideploy? [y/N]" "y" "multideploy \"dryrun\"";
        printConfirm "Start REAL multideploy? [y/N]" "y" "multideploy";
    fi
fi

rm "${TEMP_FILE}";
rm "${DIALOG_TEMP_FILE}";

exit 0;






Choose a project's number to deploy or 0 to abort: 36
[SUCCESS    ]: Selected project 'aaaaa'
[SUCCESS    ]: Found 'targets' file for this project.
[SUCCESS    ]: Found 'multitargets' file for this project.
[SUCCESS    ]: No 'ignores' file found for this project.


Enable multi target mode for this project? [y/N]:
[SUCCESS    ]: Skipped

Choose a project to deploy from [ .. ]:
[   1]: /var/www/html/aaaaa/

Select an element from list or 0 to abort: 1
[SUCCESS    ]: Selected element '/var/www/html/aaaaa/'

Start simulation deploy? [y/N]: y

[SUCCESS    ]: Sync status: sent 90.58K bytes  received 4.54K bytes  190.26K bytes/sec

Start REAL deploy? [y/N]: y

[SUCCESS    ]: Sync status: sent 15.12M bytes  received 17.17K bytes  4.32M bytes/sec
