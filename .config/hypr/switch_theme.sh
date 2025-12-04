#! /usr/bin/env bash

HX_LIGHT='theme = "kaolin-light"'
HX_DARK='theme = "jetbrains_dark"'
ALACRITTY_LIGHT='general.import = [ "onelight.toml" ]'
ALACRITTY_DARK='general.import = [ "onedark.toml" ]'


if [[ $(dconf read /org/gnome/desktop/interface/color-scheme) == "'prefer-light'" ]]; then
  dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
  sed -i "1c$HX_DARK" ~/.config/helix/config.toml
  sed -i "1c$ALACRITTY_DARK" ~/.config/alacritty/alacritty.toml
else
  dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
  sed -i "1c$HX_LIGHT" ~/.config/helix/config.toml
  sed -i "1c$ALACRITTY_LIGHT" ~/.config/alacritty/alacritty.toml
fi
