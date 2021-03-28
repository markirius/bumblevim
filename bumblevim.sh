#!/bin/bash
# bumblevim.sh
#
# Install a vim environment for better usage as a text code
#
# Version 1: Install vim files and venvs to make vim a python code editor
#
# Marcos, March 2021
#

# set destination folder for venvs
DESTINATION=.venvs

# set script path
export SCRIPT="$(readlink -f "${BASH_SOURCE[0]}")"
export DIR="$(dirname "$SCRIPT")"

packages() {
    echo black
    echo flake8
    echo isort
    echo jedi
    echo pylint
}

helptext() {
    echo "
    -i --install     install vim files and some venvs
    -u --update      update vim files, installed components and venvs
    -v --vimupdate   update and upgrade vim plugins
    -h --help        show this help
    "
}

install_venvs() {
    if [[ $(python --version) ]] && [[ $(pip --version) ]]
    then
	if [[ ! -d $HOME/$DESTINATION ]]
	then
          mkdir $HOME/$DESTINATION
	fi
        for package in $( packages )
        do
            $(python -m venv $HOME/$DESTINATION/$package)
            cd $HOME/$DESTINATION/$package
            echo $(pwd)
            . bin/activate
            pip install -U pip
            pip install $package
            deactivate
        done
    else
        echo "[!] There's no python interpreter on system!"
    fi
}

update_venvs() {
    if [[ $(python --version) ]] && [[ $(pip --version) ]]
    then
        for package in $( packages )
        do
            cd $HOME/$DESTINATION/$package
            . bin/activate
            pip install -U pip
            pip install -U $package
            deactivate
	    cd $DIR
        done
    else
        echo "[!] There's no python interpreter on system!"
    fi
}

vim_powerup() {
    if [[ $(vim --version ) ]]
    then
        cp $DIR/files/vimrc $HOME/.vimrc
        cp $DIR/files/coc-settings.json $HOME/.vim/coc-settings.json
	if [[ ! -d $HOME/.vim/vimrc ]]
	then
	  mkdir -p $HOME/.vim/vimrc
	fi
        cp $DIR/files/rc/* $HOME/.vim/vimrc/
        vim -c :PlugInstall -c sleep 5 -c :qa!
        vim -c ":CocInstall coc-python" -c "sleep 10" -c qa!
        vim -c ":CocInstall coc-css" -c "sleep 10" -c qa!
        vim -c ":CocInstall coc-html" -c "sleep 10" -c :qa!
        echo "[!] Plugins install complete."
    fi
}

vim_update() {
    vim -c :PluginUpdate -c sleep 5 -c :qa!
    vim -c :PluginUpgrade -c sleep 5 -c :qa!
}

vim_backup() {
    BACKUP=backup-$(date +%d-%m-%Y)
    if [[ ! -d $BACKUP ]]
    then
        mkdir $DIR/$BACKUP
        if [[ -f $HOME/.vimrc ]]
        then
            cp $HOME/.vimrc $DIR/$BACKUP
        fi
        if [[ -d $HOME/.vim ]]
        then
            cp -r $HOME/.vim $DIR/$BACKUP
        fi
    else
        echo "[!] Backup has already been made."
    fi
}

case "$1" in

    -i | --install)
        vim_backup
        install_venvs
        vim_powerup
        vim_update
    ;;

    -u | --update)
        update_venvs
        vim_update
    ;;

    -h | --help)
        helptext
    ;;

    *)
        vim_backup
        install_venvs
        vim_powerup
        vim_update
    ;;

esac
