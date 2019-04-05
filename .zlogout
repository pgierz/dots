# Push the config when logging out:
if [ -f ${HOME}/.deployed_machine ]; then
        cd ${HOME}
        config push > /dev/null
fi
