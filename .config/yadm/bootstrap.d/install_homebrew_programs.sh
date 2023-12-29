#!/bin/sh

system_type=$(uname -s)

if [ "$system_type" = "Darwin" ]; then

  # install homebrew if it's missing
  if ! command -v brew >/dev/null 2>&1; then
    echo "Installing homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  if [ -f "${XDG_DATA_HOME:=${HOME}/.local/share}/homebrew/Brewfile" ]; then
    echo "Updating homebrew bundle"
    brew bundle --global
  fi

fi
