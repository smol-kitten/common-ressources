#!/usr/bin/env bash
# Science / Python lab style — pairs with clean cool themes (Nord, Material)
THEME="${1:-theme}"
clear
printf "\033[2J\033[H"
printf "\n"
printf "  \033[1;34mPython 3.12.3\033[0m \033[90m(main, Apr 9 2024)\033[0m  ·  \033[36m%s\033[0m\n" "$THEME"
printf "  \033[90mType \"help\", \"copyright\", \"credits\" or \"license\" for more info.\033[0m\n"
printf "\n"
printf "  \033[32m>>>\033[0m import numpy as np\n"
printf "  \033[32m>>>\033[0m import matplotlib.pyplot as plt\n"
printf "  \033[32m>>>\033[0m x = np.linspace(0, 2 * np.pi, 1000)\n"
printf "  \033[32m>>>\033[0m print(f\"sin(π/2) = {np.sin(np.pi/2):.6f}\")\n"
printf "  \033[33msin(π/2) = 1.000000\033[0m\n"
printf "\n"
printf "  \033[32m>>>\033[0m np.linalg.eig(np.array([[2,1],[1,3]]))\n"
printf "  \033[33m(array([1.38196601, 3.61803399]),\033[0m\n"
printf "  \033[33m array([[-0.85065081,  0.52573111],\033[0m\n"
printf "  \033[33m        [ 0.52573111,  0.85065081]]))\033[0m\n"
printf "\n"
printf "  \033[32m>>>\033[0m \033[1;34m█\033[0m\n"
sleep 999
