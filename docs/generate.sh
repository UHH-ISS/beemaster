#!/usr/bin/env sh
# -*- coding: utf-8 -*-

# ./generate.sh
#
# This script generates the documentation. For, this, it sets itself up,
# including symlinks to the other repositories, the virtual environment for
# sphinx (and the connector), as well as generating doxygen docs of the C++
# repositories.
#
# Changes in certain markdown files may show no effect, if you do not have
# 'pandoc' installed.
#
# If you need to clean everything, delete each directory, starting with an
# underscore ('_').

# check tools
type doxygen >/dev/null || exit 1
type make >/dev/null || exit 1
type virtualenv >/dev/null || exit 1

# set variables
_ENVDIR=_pyenv
# -- repo paths
_HP_DIR='../../beemaster-hp'
[ -d "$_HP_DIR" ] || _HP_DIR='../../hp'
_FW_DIR='../../beemaster-acu-fw'
[ -d "$_FW_DIR" ] || _FW_DIR='../../acu-fw'
_ACU_DIR='../../beemaster-acu-portscan'
[ -d "$_ACU_DIR" ] || _ACU_DIR='../../acu-portscan'

# link directories
# -- hp repo
[ -d "$_HP_DIR" ] || { echo "Cannot find HP Repository at '$_HP_DIR'" >&2; exit 1; }
[ -L "beemaster-hp" ] || ln -s "$_HP_DIR" "beemaster-hp"

# -- framework repo
[ -d "$_FW_DIR" ] || { echo "Cannot find FW Repository at '$_FW_DIR'" >&2; exit 1; }
[ -L "beemaster-acu-fw" ] || ln -s "$_FW_DIR" "beemaster-acu-fw"

# -- acu impl repo
[ -d "$_ACU_DIR" ] || { echo "Cannot find ACU Repository at '$_ACU_DIR'" >&2; exit 1; }
[ -L "beemaster-acu-portscan" ] || ln -s "$_ACU_DIR" "beemaster-acu-portscan"


# setup enviroment
if [ ! -d "$_ENVDIR" ]; then
    cat beemaster-hp/setup.sh |\
        sed "s/^\(_ENVDIR=\).*/\1$_ENVDIR/" |\
        sed 's/^\(_INSTALL=\).*/\1true/' |\
        sed 's/^\(_DEVSETUP=\).*/\1true/' |\
        sed 's/^\(_.*REQUIREMENTS=\)\(.*\)/\1beemaster-hp\/\2/' |\
        sed 's/^\(_VIRTUALENV=\)\(.*\)/\1$(which \2)/' |\
        sed '132,133d' | sed '133,134d' |\
        bash
    #   ^^^^ seems, as if the sh on the server does other shit...
    #   or more likely, the setup.sh isn't fully sh-POSIX compatible; sry
    [ -d "$_ENVDIR" ] || { echo "Failed virtualenv setup." >&2; exit 1; }
    . $_ENVDIR/bin/activate
    # https://github.com/michaeljones/breathe/issues/292 seems not to be closed...
    pip install Sphinx==1.4.0 recommonmark breathe
    deactivate
fi

# run doxygen
[ -d "_acu-fw" ] || doxygen doxygen_acufw.conf
[ -d "_acu" ] || doxygen doxygen_acu.conf

# run sphinx
. $_ENVDIR/bin/activate
make html
deactivate
