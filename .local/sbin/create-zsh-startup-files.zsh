#!/bin/zsh -e
touch $ZDOTDIR/.zshenv
touch $ZDOTDIR/.zprofile
touch $ZDOTDIR/.zshrc
touch $ZDOTDIR/.zlogin
touch $ZDOTDIR/.zlogout

ln -s $ZDOTDIR/.zshenv   $ZDOTDIR/zshenv
ln -s $ZDOTDIR/.zprofile $ZDOTDIR/zprofile
ln -s $ZDOTDIR/.zshrc    $ZDOTDIR/zshrc
ln -s $ZDOTDIR/.zlogin   $ZDOTDIR/zlogin
ln -s $ZDOTDIR/.zlogout  $ZDOTDIR/zlogout
