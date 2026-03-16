#!/usr/bin/env bash

# Dynamic Layout Manager for Hyprland
# Manages borders, gaps, and waybar based on window count and override mode

# State file to track override mode
STATE_FILE="/tmp/hypr-layout-override"

DEFAULT_GAPS_IN=5
DEFAULT_GAPS_OUT=20
DEFAULT_BORDER=2
DEFAULT_ROUNDING=10

get_window_count() {
    hyprctl clients -j | jq "[.[] | select(.workspace.id == ($(hyprctl activeworkspace -j | jq '.id')) and .floating == false)] | length"
}

is_waybar_running() {
    pgrep -x waybar > /dev/null
}

show_waybar() {
    if ! is_waybar_running; then
        waybar &
    fi
}

hide_waybar() {
    if is_waybar_running; then
        pkill -9 waybar
    fi
}

apply_layout() {
    local count=$1
    local override=$(cat "$STATE_FILE" 2>/dev/null || echo "0")

    if [ "$override" = "1" ]; then
        hyprctl keyword general:gaps_in $DEFAULT_GAPS_IN
        hyprctl keyword general:gaps_out $DEFAULT_GAPS_OUT
        hyprctl keyword general:border_size $DEFAULT_BORDER
        hyprctl keyword decoration:rounding $DEFAULT_ROUNDING
        show_waybar
        return
    fi

    if [ "$count" -eq 1 ]; then
        hyprctl keyword general:gaps_in 0
        hyprctl keyword general:gaps_out 0
        hyprctl keyword general:border_size 0
        hyprctl keyword decoration:rounding 0
        hide_waybar
    else
        hyprctl keyword general:gaps_in $DEFAULT_GAPS_IN
        hyprctl keyword general:gaps_out $DEFAULT_GAPS_OUT
        hyprctl keyword general:border_size $DEFAULT_BORDER
        hyprctl keyword decoration:rounding $DEFAULT_ROUNDING
        hide_waybar
    fi
}

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
    local count=$(get_window_count)
    apply_layout "$count"
}

# Export toggle function for use with keybind
# export -f toggle_override

# Main event loop
if [ "$1" = "toggle" ]; then
    toggle_override
    exit 0
fi

echo "0" > "$STATE_FILE"
initial_count=$(get_window_count)
apply_layout "$initial_count"

# Listen to Hyprland events
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    event=$(echo "$line" | cut -d'>' -f1)

    case "$event" in
        openwindow|closewindow|movewindow|workspace|focusedmon)
            sleep 0.05
            count=$(get_window_count)
            apply_layout "$count"
            ;;
    esac
done
