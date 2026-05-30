#!/usr/bin/env bash
# Minimal / clean dev style — pairs with focused themes (One Dark, Material)
THEME="${1:-theme}"
clear
printf "\033[2J\033[H"
printf "\n"
printf "  \033[1;37m%s\033[0m\n" "$THEME"
printf "  \033[90m──────────────────────────────────────\033[0m\n"
printf "\n"
# 16 color swatches
printf "  "
for i in 0 1 2 3 4 5 6 7; do printf "\033[4${i}m    \033[0m"; done
printf "\n  "
for i in 0 1 2 3 4 5 6 7; do printf "\033[10${i}m    \033[0m"; done
printf "\n\n"
printf "  \033[32m❯\033[0m nvim \033[90m.\033[0m\n"
printf "  \033[32m❯\033[0m git log --oneline -3\n"
printf "  \033[33m7a1f3b2\033[0m \033[90m(HEAD)\033[0m add rice theme configs\n"
printf "  \033[33m3c8e5d1\033[0m update hyprland keybinds\n"
printf "  \033[33m9f2a4c0\033[0m initial dotfiles\n"
printf "\n"
printf "  \033[32m❯\033[0m \033[1;37m█\033[0m\n"
sleep 999
