# 🤖✨ CachyOS Expert AI Assistant

Welcome to your personal AI assistant for CachyOS! This friendly helper will guide you through system updates, troubleshoot issues, and help you find software - all through simple conversations.

## 🚀 Quick Start (One-Line Install)

Ready to get started? Just copy and paste this command into your terminal:

```bash
curl -sSL https://raw.githubusercontent.com/th3raid0r/cachyos-expert-ai/main/setup.sh | bash
```

That's it! The script will automatically:
- 📦 Install all the tools you need
- ⬇️ Download the AI assistant
- 🔑 Set up your API keys
- 🖥️ Create handy desktop shortcuts

## 🔐 Important: API Keys from Bitwarden

During setup, you'll be asked for several API keys. **Don't panic!** 😊

### Where to find them:
1. 🔍 Open your Bitwarden app
2. 🔍 Look for the **shared note from your admin**
3. 📋 Copy each key when prompted

The script will ask for these keys:
- 🤖 **CLAUDE_API_KEY** - Powers the main AI brain
- 🧠 **OPENAI_API_KEY** - Backup AI assistant
- 🌐 **JINA_API_KEY** - Helps search the web
- 🔍 **KAGI_API_KEY** - Enhanced search capabilities
- 📧 **EMAIL_SMTP_ADDR** - For email notifications
- 👤 **EMAIL_SMTP_USER** - Email username
- 🔒 **EMAIL_SMTP_PASS** - Email password (hidden when you type)

> 💡 **Pro tip:** The script remembers your keys! If you run it again later, it will only ask for missing ones.

## 🎯 What You'll Get

After installation, you'll find these helpful shortcuts on your desktop:

### 🔄 System Update Helper
Click to get help updating all your software (pacman, AUR, flatpaks, snaps)

### 💾 Disk Space Analyzer
Find out why your hard drive is getting full

### 🤖 AI Assistant Launcher
Chat directly with your AI assistant about anything CachyOS-related

## 🆘 Getting Help

Once installed, you can ask your AI assistant questions like:

- *"Help me update my system"*
- *"Why is my computer running slow?"*
- *"How do I install Discord?"*
- *"My WiFi isn't working, what should I check?"*
- *"Show me how to customize my desktop"*

## 🔄 Updating

Want the latest features? Just run the install command again:

```bash
curl -sSL https://raw.githubusercontent.com/th3raid0r/cachyos-expert-ai/main/setup.sh | bash
```

Your API keys will be preserved, and you'll get all the latest improvements! ✨

## 🛠️ Manual Installation (Alternative)

If you prefer to download first, then run:

```bash
git clone https://github.com/th3raid0r/cachyos-expert-ai.git
cd cachyos-expert-ai
chmod +x setup.sh
./setup.sh
```

## 📍 File Locations

After installation, your files will be organized like this:
- 🏠 **AI Assistant**: `~/.config/cachyos-expert/`
- ⚙️ **Configuration**: `~/.config/aichat/`
- 🖥️ **Desktop Shortcuts**: `~/Desktop/`

## 🤝 Need Help?

- 💬 Your AI assistant is designed to help with most CachyOS questions
- 🔐 Can't find the Bitwarden vault? Ask your admin
- 🐛 Something not working? Try running the install script again

---

**Happy computing with your new AI assistant!** 🎉🚀
