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
