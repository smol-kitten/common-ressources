#!/usr/bin/env bash
# macOS zsh style — pairs with bright/light themes (Solarized Light, One Light)
THEME="${1:-theme}"
clear
printf "\033[2J\033[H"
printf "\n"
printf "  \033[90mLast login: $(date '+%a %b %e %H:%M:%S') on ttys001\033[0m\n"
printf "\n"
printf "  \033[32muser\033[0m\033[37m@\033[0m\033[32mMacBook-Pro\033[0m \033[34m~\033[0m \033[90m·\033[0m \033[36m%s\033[0m \033[35m%%\033[0m ls -la\n" "$THEME"
printf "  \033[90mdrwx------   user  staff  \033[34m.config\033[0m\n"
printf "  \033[90mdrwxr-xr-x   user  staff  \033[34mDesktop\033[0m\n"
printf "  \033[90mdrwxr-xr-x   user  staff  \033[34mDocuments\033[0m\n"
printf "  \033[90mdrwxr-xr-x   user  staff  \033[34mDownloads\033[0m\n"
printf "  \033[90m-rw-r--r--   user  staff  .zshrc\033[0m\n"
printf "\n"
printf "  \033[32muser\033[0m\033[37m@\033[0m\033[32mMacBook-Pro\033[0m \033[34m~\033[0m \033[35m%%\033[0m brew install neovim\n"
printf "  \033[90m==>\033[0m Downloading \033[34mhttps://formulae.brew.sh/neovim\033[0m\n"
printf "  \033[32m==>\033[0m \033[1mInstalling neovim\033[0m\n"
printf "  \033[32m==>\033[0m \033[90mSummary: 🍺 /opt/homebrew/Cellar/neovim/0.10.0\033[0m\n"
printf "\n"
printf "  \033[32muser\033[0m\033[37m@\033[0m\033[32mMacBook-Pro\033[0m \033[34m~\033[0m \033[35m%%\033[0m \033[1;35m█\033[0m\n"
sleep 999
