#!/bin/bash
set -e

UBUNTU_SOURCES="/etc/apt/sources.list.d/ubuntu.sources"
ROS2_SOURCES="/usr/share/ros-apt-source/ros2.sources"
BACKUP_DIR="$HOME/apt-mirror-backups"

UBUNTU_CHINA="https://mirrors.tuna.tsinghua.edu.cn/ubuntu"
ROS2_CHINA="https://mirrors.tuna.tsinghua.edu.cn/ros2/ubuntu"

mkdir -p "$BACKUP_DIR"

backup_file() {
    local file="$1"
    local backup="$BACKUP_DIR/$(basename $file).bak.$(date +%Y%m%d_%H%M%S)"
    cp "$file" "$backup"
    echo "  Backed up: $backup"
}

replace_uri() {
    local file="$1"
    local new_uri="$2"
    local current
    current=$(grep "^URIs:" "$file" | head -1 | awk '{print $2}')
    if [ "$current" = "$new_uri" ]; then
        echo "  Already using target mirror, skipping."
    else
        backup_file "$file"
        sed -i "s|^URIs: .*|URIs: $new_uri|" "$file"
        echo "  Changed: $current -> $new_uri"
    fi
}

echo "=== APT Mirror Changer ==="
echo ""

echo "[1/2] Ubuntu -> China TUNA (mirrors.tuna.tsinghua.edu.cn/ubuntu)..."
[ -f "$UBUNTU_SOURCES" ] || { echo "ERROR: $UBUNTU_SOURCES not found!"; exit 1; }
replace_uri "$UBUNTU_SOURCES" "$UBUNTU_CHINA"
if grep -q "security.ubuntu.com" "$UBUNTU_SOURCES"; then
    sed -i "s|http://security.ubuntu.com/ubuntu/\?|https://mirrors.tuna.tsinghua.edu.cn/ubuntu|g" "$UBUNTU_SOURCES"
    echo "  Security URI also updated to TUNA."
fi

echo ""
echo "[2/2] ROS2 -> China TUNA (mirrors.tuna.tsinghua.edu.cn/ros2/ubuntu)..."
[ -f "$ROS2_SOURCES" ] || { echo "ERROR: $ROS2_SOURCES not found!"; exit 1; }
replace_uri "$ROS2_SOURCES" "$ROS2_CHINA"
# TUNA ROS2 mirror has no source packages — ensure deb-src is not set
if grep -q "deb-src" "$ROS2_SOURCES"; then
    sed -i 's/^Types: deb deb-src/Types: deb/' "$ROS2_SOURCES"
    echo "  Removed deb-src (TUNA ROS2 mirror has no source packages)."
fi

echo ""
echo "=== Running apt update ==="
apt update

echo ""
echo "All done!"
