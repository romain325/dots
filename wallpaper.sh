#!/bin/bash

# Wallpaper Selector Script for Hyprland
# Displays wallpaper thumbnails in rofi for easy selection

# Configuration
WALLPAPER_DIR="$HOME/.config/wallpapers/"  # Change this to your wallpaper directory
THUMBNAIL_DIR="$HOME/.cache/wallpaper-thumbnails"
THUMBNAIL_SIZE="300x300"

# Create transition directory if it doesn't exist
mkdir -p "$THUMBNAIL_DIR"

# Function to generate thumbnails
generate_thumbnails() {
    echo "Generating thumbnails..."
    for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png,webp} ; do
        [ -f "$img" ] || continue
        
        filename=$(basename "$img")
        thumbnail="$THUMBNAIL_DIR/${filename%.*}.png"
        
        # Generate thumbnail if it doesn't exist or is older than the original
        if [ ! -f "$thumbnail" ] || [ "$img" -nt "$thumbnail" ]; then
            convert "$img" -resize "$THUMBNAIL_SIZE" "$thumbnail" 
        fi
    done
}

# Function to set wallpaper with fade transition
set_wallpaper() {
    local new_wallpaper="$1"
    local current_wallpaper_file="$HOME/.cache/current-wallpaper.txt"
    
    # Get screen resolution
    resolution=$(hyprctl monitors -j | jq -r '.[0] | "\(.width)x\(.height)"')

    # Set the final wallpaper
    swaybg -i "$new_wallpaper" -m fill &
    
    notify-send "Wallpaper Changed" "$(basename "$new_wallpaper")"
}

# Check if wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Error" "Wallpaper directory not found: $WALLPAPER_DIR"
    exit 1
fi

# Generate thumbnails
generate_thumbnails

# Create a list of wallpapers with thumbnails for rofi
wallpaper_list=""
declare -A wallpaper_map

for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png,webp} ; do
    [ -f "$img" ] || continue
    
    filename=$(basename "$img")
    thumbnail="$THUMBNAIL_DIR/${filename%.*}.png"
    
    if [ -f "$thumbnail" ]; then
        wallpaper_list+="$filename\0icon\x1f$thumbnail\n"
        wallpaper_map["$filename"]="$img"
    fi
done

# Show rofi with thumbnails
selected=$(echo -en "$wallpaper_list" | rofi -dmenu \
    -i \
    -p "Select Wallpaper" \
    -show-icons \
    -theme-str 'window {width: 800px;} listview {columns: 3; lines: 3;}' \
    -theme-str 'element {orientation: vertical; padding: 10px;} element-icon {size: 8em;}' \
    -theme-str 'inputbar {enabled: false;} ' \
    -theme-str 'element-text {enabled: false;}')

# Set the selected wallpaper
if [ -n "$selected" ]; then
    full_path="${wallpaper_map[$selected]}"
    if [ -n "$full_path" ]; then
        set_wallpaper "$full_path"
    fi
fi
