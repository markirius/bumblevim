#!/bin/bash
# bumblevim.sh
#
# Install a vim environment for better usage as a text code
#
# Version 1: Install and update venv's
#
# Marcos, March 2021
#

DESTINATION=.venvs

packages() {
	echo black
	echo flake8
	echo isort
	echo jedi
	echo pylint
}

install_venvs() {
	if [[ $(python --version) ]] && [[ $(pip --version) ]]
	then
		mkdir $HOME/$DESTINATION
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
			echo $(pwd)
			. bin/activate
			pip install -U pip
			pip install -U $package
			deactivate
		done
	else
		echo "[!] There's no python interpreter on system!"
	fi
}

vim_upgrade() {

}

case "$1" in

	-i | --install)
		install_venvs
	;;

	-u | --update)
		update_venvs
	;;

esac
