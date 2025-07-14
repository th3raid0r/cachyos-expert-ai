#!/bin/bash

# CachyOS Expert AI Setup Script

# Function to check and install packages
install_pacman_packages() {
    # get all packages with pacman and return in a variable for later evaluation
    packages=$(sudo pacman -Qq)

    # Define packages to check and install
    packages_to_install=("yay" "newscheck" "jq" "argc" "python")

    # Define a package list var that is packages_to_install list, but excluding packages already installed
    packages_to_install_minus_installed=$(echo "${packages_to_install[@]}" | tr ' ' '\n' | grep -v -F -x "${packages[@]}")

    # Check and install packages using case statement
    for package in "${packages_to_install_minus_installed[@]}"; do
        case $package in
            yay)
                sudo pacman -S --noconfirm yay
                ;;
            *)
                yay -S --noconfirm $package
                ;;
        esac
    done
}

# Function to check and install python packages
install_python_packages() {
    # get all packages with pacman and return in a variable for later evaluation
    packages=$(sudo pacman -Qq)

    # Define packages to check and install
    packages_to_install=("pip" "requests" "numpy" "scipy" "matplotlib")

    # Define a package list var that is packages_to_install list, but excluding packages already installed
    packages_to_install_minus_installed=$(echo "${packages_to_install[@]}" | tr ' ' '\n' | grep -v -F -x "${packages[@]}")

    # Check and install packages using case statement
    for package in "${packages_to_install_minus_installed[@]}"; do
        case $package in
            pip)
                sudo pacman -S --noconfirm python-pip
                ;;
            *)
                # Try pacman first with python- prefix, fallback to pip
                if ! sudo pacman -S --noconfirm python-$package; then
                    pip install $package
                fi
                ;;
        esac
    done
}

install_pacman_packages
install_python_packages
