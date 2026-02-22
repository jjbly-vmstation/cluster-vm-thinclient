#!/bin/bash
# Mac thin-client setup for Windows RDP
# - Enable auto-login (manual)
# - Install Microsoft Remote Desktop (manual)
# - Create RDP profile
# - Auto-launch via LaunchAgent
#
# Usage: ./setup-mac-thinclient.sh [rdp_host] [rdp_user]

RDP_HOST="${1:-192.168.4.62}"
RDP_USER="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAUNCH_AGENT_DIR="$HOME/Library/LaunchAgents"
PLIST_NAME="com.vmstation.windows-rdp.plist"

echo "Mac Thin-Client Setup"
echo "===================="
echo "RDP Host: $RDP_HOST"
echo ""
echo "Manual steps:"
echo "1. Enable auto-login: System Settings → Users & Groups → Login Options"
echo "2. Install Microsoft Remote Desktop from Mac App Store"
echo "3. Add RDP connection: $RDP_HOST (user: $RDP_USER)"
echo ""
echo "Creating LaunchAgent to auto-open RDP on login..."

mkdir -p "$LAUNCH_AGENT_DIR"
cat > "$LAUNCH_AGENT_DIR/$PLIST_NAME" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.vmstation.windows-rdp</string>
    <key>ProgramArguments</key>
    <array>
        <string>open</string>
        <string>-a</string>
        <string>Microsoft Remote Desktop</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF

echo "LaunchAgent installed: $LAUNCH_AGENT_DIR/$PLIST_NAME"
echo ""
echo "To auto-launch RDP profile instead, edit the plist ProgramArguments to:"
echo "  open -a 'Microsoft Remote Desktop' rdp://full%20address=s:$RDP_HOST"
echo ""
echo "Load agent: launchctl load $LAUNCH_AGENT_DIR/$PLIST_NAME"
