#!/usr/bin/env bash
# Fake neofetch / fastfetch style — works with any theme
THEME="${1:-theme}"
clear
printf "\033[2J\033[H"
printf "\n"
# Arch logo (condensed)
printf "  \033[36m      /\\       \033[0m  \033[1;37muser\033[0m\033[90m@arch\033[0m\n"
printf "  \033[36m     /  \\      \033[0m  \033[90m──────────────────────────\033[0m\n"
printf "  \033[36m    /\\   \\     \033[0m  \033[33mOS:\033[0m       Arch Linux x86_64\n"
printf "  \033[36m   /  __ \\\\    \033[0m  \033[33mWM:\033[0m       Hyprland\n"
printf "  \033[36m  / /    \\ \\   \033[0m  \033[33mTerminal:\033[0m foot\n"
printf "  \033[36m /_/      \\_\\  \033[0m  \033[33mShell:\033[0m    zsh 5.9\n"
printf "  \033[0m               \033[0m  \033[33mPackages:\033[0m 1337 (pacman)\n"
printf "  \033[0m               \033[0m  \033[33mCPU:\033[0m      Ryzen 9 7950X\n"
printf "  \033[0m               \033[0m  \033[33mMemory:\033[0m   4096MiB / 65536MiB\n"
printf "  \033[0m               \033[0m  \033[33mTheme:\033[0m    \033[36m%s\033[0m\n" "$THEME"
printf "\n"
# Color blocks
printf "  "
for i in 0 1 2 3 4 5 6 7; do printf "\033[4${i}m   \033[0m"; done
printf "\n  "
for i in 0 1 2 3 4 5 6 7; do printf "\033[10${i}m   \033[0m"; done
printf "\n\n"
printf "  \033[36;1muser\033[0m\033[90m@arch\033[0m \033[34m~/dotfiles\033[0m \033[36m❯\033[0m \033[1;36m█\033[0m\n"
sleep 999
