#!/bin/bash
source ./layout.conf

# Choose target directory (/etc/skel for ISO builds, or $HOME for live testing)
TARGET_DIR="${1:-$HOME}"
XML_DIR="$TARGET_DIR/.config/xfce4/xfconf/xfce-perchannel-xml"
mkdir -p "$XML_DIR" "$TARGET_DIR/.config/autostart" "$TARGET_DIR/Pictures"

# Convert panel position word into XFCE coordinates
case "$PANEL_POSITION" in
  top)    POS_CODE="p=6;x=0;y=0" ;;
  bottom) POS_CODE="p=8;x=0;y=0" ;;
  left)   POS_CODE="p=10;x=0;y=0" ;;
  right)  POS_CODE="p=12;x=0;y=0" ;;
  *)      POS_CODE="p=8;x=0;y=0" ;;
esac

# 1. Apply GTK Theme & Icons
cat << EOF > "$XML_DIR/xsettings.xml"
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="$GTK_THEME"/>
    <property name="IconThemeName" type="string" value="$ICON_THEME"/>
  </property>
</channel>
EOF

# 2. Apply Window Borders
cat << EOF > "$XML_DIR/xfwm4.xml"
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="$WINDOW_BORDER"/>
  </property>
</channel>
EOF

# 3. Apply Panel Position, Size & Dark Mode
cat << EOF > "$XML_DIR/xfce4-panel.xml"
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="$POS_CODE"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="$PANEL_SIZE"/>
      <property name="dark-mode" type="bool" value="$PANEL_DARK_MODE"/>
    </property>
  </property>
</channel>
EOF

# 4. Toggle Plank Dock
if [ "$ENABLE_PLANK_DOCK" = "true" ]; then
  cat << 'EOF' > "$TARGET_DIR/.config/autostart/plank.desktop"
[Desktop Entry]
Type=Application
Name=Plank
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
else
  rm -f "$TARGET_DIR/.config/autostart/plank.desktop"
fi

# 5. Copy Local Wallpaper & Set Desktop Background
if [ -n "$WALLPAPER_PATH" ] && [ -f "$WALLPAPER_PATH" ]; then
  sudo mkdir -p /usr/share/backgrounds
  sudo cp "$WALLPAPER_PATH" /usr/share/backgrounds/shark-wallpaper.jpg
  cat << 'EOF' > "$XML_DIR/xfce4-desktop.xml"
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="last-image" type="string" value="/usr/share/backgrounds/shark-wallpaper.jpg"/>
          <property name="image-style" type="int" value="5"/>
        </property>
      </property>
    </property>
  </property>
</channel>
EOF
fi
