#! /usr/bin/env bash

dirs=(
  helix
  hypr
  fish
  alacritty
  mako
)

for dir in ${dirs[@]}; do
  ln --symbolic -n $HOME/dotfiles/.config/$dir $HOME/.config/$dir
done
