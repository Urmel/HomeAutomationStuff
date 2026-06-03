#!/bin/bash
#
# Init Script to ensure that GraalPy venv is symlinked to
# folder outside of userdata/cache
#
export VENVDIR=/openhab/userdata/cache/org.openhab.automation.pythonscripting/venv
export VENVDIR_Backup=${VENVDIR}_`date +"%y%m%d-%H%M"`
export VENVDIR_External=/venvs/graalpy

echo Ensure that GraalPy VENV is symlinked outside userdata ...

if [ ! -L $VENVDIR ]; then

  if [ -d $VENVDIR ]; then
    echo "GraalPy venv dir exists locally, not symlinked."
    mv $VENVDIR $VENVDIR_Backup
    echo "Backed up to $VENVDIR_Backup"
  fi

  # First make sure, the dir above exists (not the case for first start)
  mkdir -p /openhab/userdata/cache/org.openhab.automation.pythonscripting
  ln -s $VENVDIR_External $VENVDIR
  echo "Created symlink to $VENVDIR_External"

else

  echo "GraalPy venv is symlinked - OK"

fi
