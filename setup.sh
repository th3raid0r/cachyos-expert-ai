#!/bin/bash

# CachyOS Expert AI Setup Script

# Function to check and install packages
install_pacman_packages() {
    # get all packages with pacman and return in a variable for later evaluation
    packages=$(sudo pacman -Qq)

    # Define packages to check and install
    packages_to_install=("yay" "newscheck" "jq" "argc" "python" "git" "aichat")

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

# Function to clone the repository
clone_repository() {
    echo "Setting up CachyOS Expert AI repository..."

    # Define the target directory
    TARGET_DIR="$HOME/.config/cachyos-expert"

    # Create the .config directory if it doesn't exist
    mkdir -p "$HOME/.config"

    # Remove existing directory to ensure clean install/update
    if [ -d "$TARGET_DIR" ]; then
        echo "Removing existing installation for clean update..."
        rm -rf "$TARGET_DIR"
    fi

    # Clone the repository to the target directory
    git clone https://github.com/th3raid0r/cachyos-expert-ai.git "$TARGET_DIR"

    # Change to the repository directory
    cd "$TARGET_DIR"
    echo "Repository installed/updated at $TARGET_DIR"
}

# Function to get the value of a variable from .env file
get_env_value() {
    local env_file="$1"
    local var_name="$2"

    if [ -f "$env_file" ]; then
        grep "^${var_name}=" "$env_file" | cut -d'=' -f2- | head -n1
    fi
}

# Function to check if a variable is missing or empty in .env file
is_var_missing() {
    local env_file="$1"
    local var_name="$2"
    local value=$(get_env_value "$env_file" "$var_name")

    if [ -z "$value" ]; then
        return 0  # missing or empty
    else
        return 1  # present and non-empty
    fi
}

# Function to render environment file
setup_config() {
    echo "Setting up environment variables..."

    # Define all required variables
    declare -A env_vars
    env_vars["CLAUDE_API_KEY"]=""
    env_vars["OPENAI_API_KEY"]=""
    env_vars["JINA_API_KEY"]=""
    env_vars["KAGI_API_KEY"]=""
    env_vars["EMAIL_SMTP_ADDR"]=""
    env_vars["EMAIL_SMTP_USER"]=""
    env_vars["EMAIL_SMTP_PASS"]=""

    # Load existing values if .env exists
    if [ -f ".env" ]; then
        echo "Found existing .env file, checking for missing variables..."
        for var_name in "${!env_vars[@]}"; do
            existing_value=$(get_env_value ".env" "$var_name")
            if [ -n "$existing_value" ]; then
                env_vars["$var_name"]="$existing_value"
            fi
        done
    fi

    # Check which variables need to be prompted for
    missing_vars=()
    for var_name in "${!env_vars[@]}"; do
        if [ -z "${env_vars[$var_name]}" ]; then
            missing_vars+=("$var_name")
        fi
    done

    # Prompt for missing variables
    if [ ${#missing_vars[@]} -gt 0 ]; then
        echo "The following variables need to be configured:"
        printf '%s\n' "${missing_vars[@]}"
        echo ""
        echo "Please retrieve the API keys from the shared Bitwarden note from the admin."
        echo ""

        for var_name in "${missing_vars[@]}"; do
            if [ "$var_name" = "EMAIL_SMTP_ADDR" ] || [ "$var_name" = "EMAIL_SMTP_USER" ]; then
                read -p "Enter $var_name: " user_input
            else
                read -s -p "Enter $var_name: " user_input
                echo ""
            fi
            env_vars["$var_name"]="$user_input"
        done
    else
        echo "All environment variables are already configured."
    fi

    # Create the environment file content
    env_content="CLAUDE_API_KEY=${env_vars[CLAUDE_API_KEY]}
OPENAI_API_KEY=${env_vars[OPENAI_API_KEY]}
JINA_API_KEY=${env_vars[JINA_API_KEY]}
KAGI_API_KEY=${env_vars[KAGI_API_KEY]}
EMAIL_SMTP_ADDR=${env_vars[EMAIL_SMTP_ADDR]}
EMAIL_SMTP_USER=${env_vars[EMAIL_SMTP_USER]}
EMAIL_SMTP_PASS=${env_vars[EMAIL_SMTP_PASS]}"

    # Write to .env file in current directory
    echo "$env_content" > .env
    echo "Updated .env file in current directory."

    # Create ~/.config/aichat directory if it doesn't exist
    mkdir -p ~/.config/aichat

    # Copy .env to ~/.config/aichat/.env
    cp .env ~/.config/aichat/.env
    cp config.yaml ~/.config/aichat/config.yaml
    echo "Copied .env and config.yaml to ~/.config/aichat/"

    # Symlink contents of CachyOS Expert AI
    ln -s ~/.config/cachyos-expert-ai "$(aichat --info | sed -n 's/^functions_dir\s\+//p')"
    echo "Created symbolic link for CachyOS Expert AI."
}

install_default_actions() {
    echo "Installing default actions..."

    # Create Desktop directory if it doesn't exist
    mkdir -p "$HOME/Desktop"

    # Copy desktop file templates to user's desktop
    local desktop_templates=(
        "cachyos-expert-update-system.desktop"
        "cachyos-expert-disk-space.desktop"
        "cachyos-expert-software-search.desktop"
        "cachyos-expert-launcher.desktop"
    )

    for template in "${desktop_templates[@]}"; do
        if [ -f "desktop-templates/$template" ]; then
            cp "desktop-templates/$template" "$HOME/Desktop/"
            chmod +x "$HOME/Desktop/$template"
            echo "Installed desktop shortcut: $template"
        else
            echo "Warning: Template not found: desktop-templates/$template"
        fi
    done

    echo "Default actions installed on Desktop."
}

# install_pacman_packages
#install_python_packages not yet necessary
# clone_repository
# setup_config
install_default_actions
