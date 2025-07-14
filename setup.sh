#!/bin/bash

# 🚀 CachyOS Expert AI Setup - Let's get you started! 🤖✨

# 📦 Installing the tools we need for your AI assistant
install_pacman_packages() {
    echo "📋 Checking what software you already have..."
    packages=$(sudo pacman -Qq)

    echo "🛠️  Getting the essential tools ready..."
    packages_to_install=("yay" "newscheck" "jq" "argc" "python")

    packages_to_install_minus_installed=$(echo "${packages_to_install[@]}" | tr ' ' '\n' | grep -v -F -x "${packages[@]}")

    for package in "${packages_to_install_minus_installed[@]}"; do
        echo "⬇️  Installing $package..."
        case $package in
            yay)
                sudo pacman -S --noconfirm yay
                ;;
            *)
                yay -S --noconfirm $package
                ;;
        esac
    done
    echo "✅ All essential tools are ready!"
}

# 🐍 Setting up Python extras (not needed right now, but ready for the future!)
install_python_packages() {
    echo "🔍 Checking Python packages..."
    packages=$(sudo pacman -Qq)

    echo "🐍 Preparing Python tools..."
    packages_to_install=("pip" "requests" "numpy" "scipy" "matplotlib")

    packages_to_install_minus_installed=$(echo "${packages_to_install[@]}" | tr ' ' '\n' | grep -v -F -x "${packages[@]}")

    for package in "${packages_to_install_minus_installed[@]}"; do
        echo "⬇️  Getting Python package: $package..."
        case $package in
            pip)
                sudo pacman -S --noconfirm python-pip
                ;;
            *)
                if ! sudo pacman -S --noconfirm python-$package; then
                    pip install $package
                fi
                ;;
        esac
    done
    echo "✅ Python is all set!"
}

# 📥 Getting your AI assistant files ready
clone_repository() {
    echo "🏠 Setting up your personal AI assistant..."

    TARGET_DIR="$HOME/.config/cachyos-expert"

    echo "📁 Creating your config folder..."
    mkdir -p "$HOME/.config"

    if [ -d "$TARGET_DIR" ]; then
        echo "🔄 Updating to the latest version..."
        rm -rf "$TARGET_DIR"
    fi

    echo "⬇️  Downloading the AI assistant..."
    git clone https://github.com/th3raid0r/cachyos-expert-ai.git "$TARGET_DIR"

    cd "$TARGET_DIR"
    echo "✨ Your AI assistant is ready at $TARGET_DIR"
}

# 🔍 Helper to find saved settings
get_env_value() {
    local env_file="$1"
    local var_name="$2"

    if [ -f "$env_file" ]; then
        grep "^${var_name}=" "$env_file" | cut -d'=' -f2- | head -n1
    fi
}

# 🤔 Check if we need to ask for this setting
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

# 🔑 Setting up your AI keys (the secret codes that make it work!)
setup_config() {
    echo "🔑 Let's configure your AI assistant..."

    declare -A env_vars
    env_vars["CLAUDE_API_KEY"]=""
    env_vars["OPENAI_API_KEY"]=""
    env_vars["JINA_API_KEY"]=""
    env_vars["KAGI_API_KEY"]=""
    env_vars["EMAIL_SMTP_ADDR"]=""
    env_vars["EMAIL_SMTP_USER"]=""
    env_vars["EMAIL_SMTP_PASS"]=""

    if [ -f ".env" ]; then
        echo "🔍 Found your saved settings, checking what's missing..."
        for var_name in "${!env_vars[@]}"; do
            existing_value=$(get_env_value ".env" "$var_name")
            if [ -n "$existing_value" ]; then
                env_vars["$var_name"]="$existing_value"
            fi
        done
    fi

    missing_vars=()
    for var_name in "${!env_vars[@]}"; do
        if [ -z "${env_vars[$var_name]}" ]; then
            missing_vars+=("$var_name")
        fi
    done

    if [ ${#missing_vars[@]} -gt 0 ]; then
        echo "🔧 We need to set up these API keys:"
        printf '   • %s\n' "${missing_vars[@]}"
        echo ""
        echo "💡 Ask your admin for the Bitwarden shared note with all the keys!"
        echo "🔒 Don't worry - these stay private on your computer."
        echo ""

        for var_name in "${missing_vars[@]}"; do
            if [ "$var_name" = "EMAIL_SMTP_PASS" ]; then
                read -s -p "🔐 Enter $var_name (hidden): " user_input
                echo ""
            else
                read -p "🔑 Enter $var_name: " user_input
            fi
            env_vars["$var_name"]="$user_input"
        done
    else
        echo "✅ All your API keys are already set up!"
    fi

    env_content="CLAUDE_API_KEY=${env_vars[CLAUDE_API_KEY]}
OPENAI_API_KEY=${env_vars[OPENAI_API_KEY]}
JINA_API_KEY=${env_vars[JINA_API_KEY]}
KAGI_API_KEY=${env_vars[KAGI_API_KEY]}
EMAIL_SMTP_ADDR=${env_vars[EMAIL_SMTP_ADDR]}
EMAIL_SMTP_USER=${env_vars[EMAIL_SMTP_USER]}
EMAIL_SMTP_PASS=${env_vars[EMAIL_SMTP_PASS]}"

    echo "$env_content" > .env
    echo "💾 Saved your settings!"

    mkdir -p ~/.config/aichat

    cp .env ~/.config/aichat/.env
    echo "📋 Copied settings to the right place for your AI!"

    cp config.yaml ~/.config/aichat/config.yaml
    echo "📋 Copied config file too!"

    # Symlink contents of CachyOS Expert AI
    ln -s ~/.config/cachyos-expert-ai "$(aichat --info | sed -n 's/^functions_dir\s\+//p')"
    echo "🔗 Connected AI assistant to your system!"
}

install_default_actions() {
    echo "🖥️  Creating handy shortcuts on your desktop..."

    mkdir -p "$HOME/Desktop"

    local desktop_templates=(
        "cachyos-expert-update-system.desktop"
        "cachyos-expert-disk-space.desktop"
        "cachyos-expert-launcher.desktop"
    )

    echo "✨ Adding these helpful shortcuts:"
    for template in "${desktop_templates[@]}"; do
        if [ -f "desktop-templates/$template" ]; then
            cp "desktop-templates/$template" "$HOME/Desktop/"
            chmod +x "$HOME/Desktop/$template"
            case $template in
                *update-system*) echo "   🔄 System Update Helper" ;;
                *disk-space*) echo "   💾 Disk Space Analyzer" ;;
                *launcher*) echo "   🤖 AI Assistant Launcher" ;;
            esac
        else
            echo "⚠️  Oops! Couldn't find: $template"
        fi
    done

    echo "🎉 Your desktop shortcuts are ready to use!"
}

install_pacman_packages
#install_python_packages not yet necessary
clone_repository
setup_config
install_default_actions
