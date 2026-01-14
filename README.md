# 📖 JAM-X User Manual

## 🛠 System Requirements
- **OS:** Kali Linux or any Debian-based distro.
- **Hardware:** A Bluetooth adapter (Internal or USB Dongle).
- **Dependencies:** `bluez`, `bluez-btit-tools`, `bluez-obsolete-tools`.



## 🎮 How to Use JAM_X.sh

### Step 1: Configuration
Ensure your Bluetooth adapter is plugged in. The script defaults to `hci1`. If your adapter is `hci0`, open `JAM_X.sh` in a text editor and change the `INTERFACE` variable at the top.

### Step 2: Dependency Check
Before your first run, go to **Option 3 (Help & Auto-Install)** and select **Option 1**. This ensures all legacy Bluetooth tools are installed and ready.

### Step 3: Target Discovery
Select **Option 2 (Start Continuous Scan)**. 
- The list will update every 5 seconds without clearing the screen.
- When you see your target device, press **Ctrl+C**. This pauses the scan and opens the selection menu.

### Step 4: Launching an Attack
Select the **ID** number of your target. Choose the method that best fits the device type:
- **For Earphones:** Use **Option D (Force Disconnect)**. This is designed to break the link between a mobile and a headset.
- **For Phones:** Use **Option B**. It spams connection requests to freeze the user interface.

- Markdown

# 🛡️ JAM-X v0.4.0
### Advanced Bluetooth Pentesting & Signal Analysis Utility
**Developed by:** [kanak-india](https://github.com/kanak-india)

JAM-X is a powerful Bash-based security tool designed for auditing Bluetooth device resilience.

## 📥 Quick Install
```bash
git clone [https://github.com/kanak-india/JAM-X.git](https://github.com/kanak-india/JAM-X.git)
cd JAM-X
chmod +x JAM_X.sh
sudo ./JAM_X.sh



## ⚠️ Safety & Legal
Only use JAM-X on hardware you own. This tool is for educational and authorized testing purposes only.

Would you like me to help you format a LinkedIn post to announce the release of JAM-X to your professional network?
