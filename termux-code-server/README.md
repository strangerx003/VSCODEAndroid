# 📱 VS Code on Android via Termux + code-server

Run the **full desktop VS Code** on your Android phone/tablet  
using **Termux** + **code-server** — accessible entirely through your phone's browser.

**You DO NOT need Windows VS Code.** `code-server` is the **actual VS Code desktop application** packaged for Linux, not a clone or alternative editor. The setup script downloads and installs the complete VS Code binary inside Termux automatically.

### 🖥️ Is it the Real VS Code UI?
**Yes.** `code-server` uses the exact same VS Code editor UI with:
- ✅ Full Visual Studio Code interface (identical to Windows/Mac/Linux desktop)
- ✅ All standard VS Code features: IntelliSense, debugging, extensions, Git integration
- ✅ Same settings sync, keybindings, and themes
- ✅ Integrated terminal
- ✅ Full extension marketplace support
- ✅ Workspace support with folders and settings
- ✅ Command palette, split editor, multi-root workspaces
- ✅ Remote SSH, Docker, WSL extensions work too

The only difference is the **interface is rendered in your browser** instead of a native desktop window, but everything else is 100% the same VS Code experience.

---

## 🧠 How It Works

```
┌─────────────────────────────────────────┐
│              Android Device              │
│                                         │
│  ┌──────────┐     ┌──────────────────┐  │
│  │ Browser  │────▶│   code-server    │  │
│  │ (Chrome) │     │  (VS Code in     │  │
│  │          │     │   browser)       │  │
│  │ localhost│     │  Port 8080       │  │
│  └──────────┘     └──────┬───────────┘  │
│                          │               │
│                   ┌──────▼───────────┐   │
│                   │     Termux       │   │
│                   │  (Linux env)     │   │
│                   └──────────────────┘   │
└─────────────────────────────────────────┘
```

- **Termux** provides a Linux userland on Android (no root required)
- **code-server** is the open-source VS Code that runs in a browser
- You open `http://localhost:8080` in Chrome and get full VS Code

---

## 🚀 Quick Start

### Step 1 — Install Termux
Install **Termux** from **F-Droid** (NOT Google Play — the Play Store version is outdated):

👉 [https://f-droid.org/packages/com.termux/](https://f-droid.org/packages/com.termux/)

Also install **Termux:API** (for extra features):
👉 [https://f-droid.org/packages/com.termux.api/](https://f-droid.org/packages/com.termux.api/)

### Step 2 — Run the Setup Script
Open Termux and paste:

```bash
# Download and run the setup script
curl -fsSL https://raw.githubusercontent.com/coder/code-server/main/install.sh | sh
```

Or use the included setup script:

```bash
# 1. Copy setup-termux.sh to your device
# 2. In Termux, navigate to the script location
# 3. Run:
bash setup-termux.sh
```

### Step 3 — Start code-server
```bash
code-server --auth none --bind-addr 0.0.0.0:8080
```

### Step 4 — Open in Browser
Open **Chrome** (or any browser) and go to:

```
http://localhost:8080
```

🎉 You now have **VS Code running on your Android phone!**

---

## 📁 Included Files

| File | Purpose |
|------|---------|
| `setup-termux.sh` | One-shot installer (deps + code-server + launchers) |
| `pwa-launcher.html` | Browser launcher with status checker |
| `manifest.json` | PWA manifest for "Add to Home Screen" |
| `sw.js` | Service worker for offline launcher caching |
| `icon-192.png` / `icon-512.png` | PWA icons |

---

## 🔧 Configuration

Edit `~/.config/code-server/config.yaml` after install:

```yaml
bind-addr: 0.0.0.0:8080
auth: password
password: your-password-here
cert: false
```

- **auth: none** — No password (only use on trusted networks)
- **auth: password** — Password required
- **cert: true** — Enable HTTPS (requires certificate setup)

---

## 📦 Recommended Extensions

These work great on mobile:

```
code-server --install-extension ms-python.python
code-server --install-extension esbenp.prettier-vscode
code-server --install-extension dbaeumer.vscode-eslint
code-server --install-extension ritwickdey.liveserver
code-server --install-extension github.copilot
```

---

## 🎮 Touch-Friendly Settings

Add to VS Code `settings.json`:

```json
{
  "editor.fontSize": 16,
  "editor.tabSize": 2,
  "terminal.integrated.fontSize": 14,
  "workbench.touchBar.enabled": true,
  "editor.minimap.enabled": false,
  "workbench.statusBar.visible": true,
  "workbench.activityBar.visible": true
}
```

---

## 🔗 Access from Other Devices (Optional)

To access code-server from your PC on the same WiFi:

1. Find your phone's IP in Termux: `ip addr show wlan0`
2. On PC browser, open: `http://<PHONE_IP>:8080`

---

## 💡 Also Runs

Since Termux gives you a Linux environment, you can also run:

| Tool | Command |
|------|---------|
| Node.js | `pkg install nodejs` |
| Python | `pkg install python` |
| Git | `pkg install git` |
| Nginx | `pkg install nginx` |
| PostgreSQL | `pkg install postgresql` |
| Docker (rootless) | `pkg install root-repo && pkg install docker` |

---

## 🐳 Also: Docker Images

Since you asked about Docker-style images, here are pre-built options for **code-server** / **VS Code in Docker** that you can run from Termux if you install Docker:

- **codercom/code-server** — Official code-server image
- **linuxserver/code-server** — LinuxServer.io build
- **nextcloud/code-server** — With Nextcloud integration

If you install Docker in Termux (`pkg install docker`), you can run any official VS Code / code-server Docker image the same way.

## 🚀 Upload to GitHub as `vscode-android`

1. Go to https://github.com/new and create a new **public** repository named:
   ```
   vscode-android
   ```
2. In this project folder, run:
   ```bash
   git remote add origin https://github.com/$(git config user.name)/vscode-android.git
   git branch -M main
   git push -u origin main
   ```

## ⚠️ Notes

- Termux from **Google Play is outdated** — always use **F-Droid**
- code-server uses ~200-400 MB RAM — works well on 4GB+ devices
- For heavy work, consider a VPS + code-server instead
- Battery optimization: disable battery optimization for Termux in Android settings
