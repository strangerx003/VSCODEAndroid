#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  Termux code-server Setup Script
#  Installs all dependencies and code-server for VS Code
#  in your Android browser.
# ============================================================

set -e  # Exit on error

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════╗"
echo "║     VS Code Server - Termux Installer        ║"
echo "║     code-server + dependencies               ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"

# --------------------------------------------------
# Step 1: Update & upgrade packages
# --------------------------------------------------
echo -e "${YELLOW}[1/6] Updating Termux packages...${NC}"
pkg update -y && pkg upgrade -y

# --------------------------------------------------
# Step 2: Install essential dependencies
# --------------------------------------------------
echo -e "${YELLOW}[2/6] Installing essential packages...${NC}"
pkg install -y \
    curl \
    wget \
    git \
    tar \
    gzip \
    nano \
    vim \
    openssh \
    nodejs \
    python \
    python-pip \
    build-essential \
    binutils \
    yarn \
    neovim \
    ripgrep \
    fd

# --------------------------------------------------
# Step 3: Install code-server
# --------------------------------------------------
echo -e "${YELLOW}[3/6] Installing code-server...${NC}"

# Use the official code-server install script
curl -fsSL https://code-server.dev/install.sh | sh

# Verify installation
if command -v code-server &> /dev/null; then
    echo -e "${GREEN}✓ code-server installed successfully!${NC}"
    CODE_SERVER_VERSION=$(code-server --version | head -1)
    echo -e "${GREEN}  Version: ${CODE_SERVER_VERSION}${NC}"
else
    echo -e "${RED}✗ code-server installation failed.${NC}"
    echo -e "${YELLOW}  Trying manual install...${NC}"
    
    # Manual fallback: download latest release
    LATEST_URL=$(curl -s https://api.github.com/repos/coder/code-server/releases/latest | grep "browser_download_url.*linux-arm64.tar.gz" | cut -d '"' -f 4 | head -1)

    if [ -z "$LATEST_URL" ]; then
        echo -e "${RED}  Could not find ARM64 release. Trying ARMv7...${NC}"
        LATEST_URL=$(curl -s https://api.github.com/repos/coder/code-server/releases/latest | grep "browser_download_url.*linux-armv7l.tar.gz" | cut -d '"' -f 4 | head -1)
    fi

    if [ -n "$LATEST_URL" ]; then
        echo -e "${YELLOW}  Downloading: ${LATEST_URL}${NC}"
        cd /tmp
        curl -fsSLO "$LATEST_URL"
        tar -xzf code-server-*.tar.gz
        cd code-server-*
        cp -r * $PREFIX/
        echo -e "${GREEN}✓ code-server installed manually!${NC}"
    else
        echo -e "${RED}✗ Could not find a suitable code-server release.${NC}"
        exit 1
    fi
fi

# --------------------------------------------------
# Step 4: Create config directory & config file
# --------------------------------------------------
echo -e "${YELLOW}[4/6] Setting up code-server configuration...${NC}"

CONFIG_DIR="$HOME/.config/code-server"
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_DIR/config.yaml" << 'YAMLEOF'
bind-addr: 0.0.0.0:8080
auth: password
password: coder123  # CHANGE THIS!
cert: false

# Optional: disable telemetry
disable-telemetry: true

# Optional: disable update check
disable-update-check: false

# User data directory
user-data-dir: ~/.local/share/code-server

# Extensions directory
extensions-dir: ~/.local/share/code-server/extensions
YAMLEOF

echo -e "${GREEN}✓ Configuration created at ${CONFIG_DIR}/config.yaml${NC}"
echo -e "${RED}  ⚠ CHANGE THE DEFAULT PASSWORD! Edit: ${CONFIG_DIR}/config.yaml${NC}"

# --------------------------------------------------
# Step 5: Install recommended extensions
# --------------------------------------------------
echo -e "${YELLOW}[5/6] Installing recommended extensions...${NC}"

EXTENSIONS=(
    "ms-python.python"
    "esbenp.prettier-vscode"
    "dbaeumer.vscode-eslint"
    "ritwickdey.LiveServer"
    "ms-vscode.vscode-typescript-next"
    "formulahendry.auto-rename-tag"
    "naumovs.color-highlight"
    "oderwat.indent-rainbow"
    "pkief.material-icon-theme"
    "zhuangtongfa.material-theme"
)

for ext in "${EXTENSIONS[@]}"; do
    echo -e "  Installing: ${ext}..."
    code-server --install-extension "$ext" 2>/dev/null || echo -e "    ${YELLOW}⚠ Skipped (may not be available)${NC}"
done

echo -e "${GREEN}✓ Extensions installed!${NC}"

# --------------------------------------------------
# Step 6: Create helper scripts
# --------------------------------------------------
echo -e "${YELLOW}[6/6] Creating launcher scripts...${NC}"

# Start script
cat > "$HOME/start-code-server.sh" << 'STARTEOF'
#!/data/data/com.termux/files/usr/bin/bash
# Start code-server with no auth (for local use)
echo "Starting code-server on http://localhost:8080 ..."
code-server --auth none --bind-addr 0.0.0.0:8080 "$HOME"
STARTEOF

chmod +x "$HOME/start-code-server.sh"

# Password-protected start script
cat > "$HOME/start-code-server-auth.sh" << 'AUTHEOF'
#!/data/data/com.termux/files/usr/bin/bash
# Start code-server with password auth
echo "Starting code-server on http://localhost:8080 (password required)"
code-server --bind-addr 0.0.0.0:8080 "$HOME"
AUTHEOF

chmod +x "$HOME/start-code-server-auth.sh"

# Stop script
cat > "$HOME/stop-code-server.sh" << 'STOPEOF'
#!/data/data/com.termux/files/usr/bin/bash
# Stop all code-server processes
pkill -f code-server && echo "code-server stopped." || echo "code-server was not running."
STOPEOF

chmod +x "$HOME/stop-code-server.sh"

# Status script
cat > "$HOME/code-server-status.sh" << 'STATUSEOF'
#!/data/data/com.termux/files/usr/bin/bash
if pgrep -f code-server > /dev/null; then
    echo "✓ code-server IS running"
    echo "  Process(es):"
    ps aux | grep code-server | grep -v grep
else
    echo "✗ code-server is NOT running"
fi
STATUSEOF

chmod +x "$HOME/code-server-status.sh"

# --------------------------------------------------
# Setup boot auto-start
# --------------------------------------------------
mkdir -p "$HOME/.termux/boot"
cat > "$HOME/.termux/boot/start-code-server" << 'BOOTEOF'
#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock
code-server --bind-addr 0.0.0.0:8080 &
BOOTEOF

chmod +x "$HOME/.termux/boot/start-code-server"

# --------------------------------------------------
# Create a wrapper script for the full PATH
# --------------------------------------------------
cat > "$PREFIX/bin/cs" << 'CSEOF'
#!/data/data/com.termux/files/usr/bin/bash
# cs - Quick code-server launcher
case "${1:-}" in
    start)
        bash ~/start-code-server.sh
        ;;
    start-auth)
        bash ~/start-code-server-auth.sh
        ;;
    stop)
        bash ~/stop-code-server.sh
        ;;
    status)
        bash ~/code-server-status.sh
        ;;
    *)
        echo "Usage: cs {start|start-auth|stop|status}"
        echo ""
        echo "  start        Start code-server (no password)"
        echo "  start-auth   Start code-server (with password)"  
        echo "  stop         Stop code-server"
        echo "  status       Check if code-server is running"
        ;;
esac
CSEOF

chmod +x "$PREFIX/bin/cs"

# --------------------------------------------------
# Done!
# --------------------------------------------------
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✓  Installation Complete!                  ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📋 Quick Commands:${NC}"
echo -e "  ${YELLOW}cs start${NC}        → Start code-server (no password)"
echo -e "  ${YELLOW}cs start-auth${NC}   → Start code-server (with password)"
echo -e "  ${YELLOW}cs stop${NC}         → Stop code-server"
echo -e "  ${YELLOW}cs status${NC}       → Check if running"
echo ""
echo -e "${BLUE}🔗 Then open in your browser:${NC}"
echo -e "  ${GREEN}http://localhost:8080${NC}"
echo ""
echo -e "${RED}⚠ IMPORTANT: Change the default password!${NC}"
echo -e "  Edit: ${YELLOW}nano ~/.config/code-server/config.yaml${NC}"
echo ""
echo -e "${BLUE}📂 Your files are in:${NC} ${YELLOW}$HOME/storage/shared${NC}  (if storage is set up)"
echo -e "  Run ${YELLOW}termux-setup-storage${NC} first to access phone storage."
echo ""