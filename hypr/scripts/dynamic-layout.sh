#!/usr/bin/env bash

# Dynamic Layout Manager for Hyprland
# Manages borders, gaps, and waybar based on window count and override mode

# State file to track override mode
STATE_FILE="/tmp/hypr-layout-override"

# Default values from your config
DEFAULT_GAPS_IN=5
DEFAULT_GAPS_OUT=20
DEFAULT_BORDER=2
DEFAULT_ROUNDING=10


# Function to get window count on active workspace
get_window_count() {
    # Count non-floating normal windows on active workspace
    hyprctl clients -j | jq "[.[] | select(.workspace.id == ($(hyprctl activeworkspace -j | jq '.id')) and .floating == false)] | length"
}

# Function to check if waybar is running
is_waybar_running() {
    pgrep -x waybar > /dev/null
}

# Function to show waybar
show_waybar() {
    if ! is_waybar_running; then
        waybar &
    fi
}

# Function to hide waybar
hide_waybar() {
    if is_waybar_running; then
        pkill -9 waybar
    fi
}

# Function to apply layout based on window count
apply_layout() {
    local count=$1
    local override=$(cat "$STATE_FILE" 2>/dev/null || echo "0")

    # If override mode is active, show everything
    if [ "$override" = "1" ]; then
        hyprctl keyword general:gaps_in $DEFAULT_GAPS_IN
        hyprctl keyword general:gaps_out $DEFAULT_GAPS_OUT
        hyprctl keyword general:border_size $DEFAULT_BORDER
        hyprctl keyword decoration:rounding $DEFAULT_ROUNDING
        show_waybar
        return
    fi

    # Apply layout based on window count
    if [ "$count" -eq 1 ]; then
        # One window: fullscreen mode - no gaps, no border, no waybar
        hyprctl keyword general:gaps_in 0
        hyprctl keyword general:gaps_out 0
        hyprctl keyword general:border_size 0
        hyprctl keyword decoration:rounding 0
        hide_waybar
    else
        # Multiple windows: add gaps and borders, keep waybar hidden
        hyprctl keyword general:gaps_in $DEFAULT_GAPS_IN
        hyprctl keyword general:gaps_out $DEFAULT_GAPS_OUT
        hyprctl keyword general:border_size $DEFAULT_BORDER
        hyprctl keyword decoration:rounding $DEFAULT_ROUNDING
        hide_waybar
    fi
}

# Function to toggle override mode
toggle_override() {
    local current=$(cat "$STATE_FILE" 2>/dev/null || echo "0")
    echo "$STATE_FILE"
    cat "$STATE_FILE"
    cat $STATE_FILE
    if [ "$current" = "0" ]; then
        echo "1" > "$STATE_FILE"
    else
        echo "0" > "$STATE_FILE"
    fi
    # Reapply layout with new override state
    local count=$(get_window_count)
    apply_layout "$count"
}

# Export toggle function for use with keybind
# export -f toggle_override

# Main event loop
if [ "$1" = "toggle" ]; then
    # Called by keybind to toggle override mode
    toggle_override
    exit 0
fi

# Initial setup
echo "0" > "$STATE_FILE"
initial_count=$(get_window_count)
apply_layout "$initial_count"

# Listen to Hyprland events
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    event=$(echo "$line" | cut -d'>' -f1)

    # React to window open/close/move events
    case "$event" in
        openwindow|closewindow|movewindow|workspace|focusedmon)
            # Small delay to let Hyprland update its state
            sleep 0.05
            count=$(get_window_count)
            apply_layout "$count"
            ;;
    esac
done
