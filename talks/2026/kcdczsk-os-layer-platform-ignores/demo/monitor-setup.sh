#!/bin/bash
# ABOUTME: Starts a VNC-hosted browser viewable on both laptop and projector simultaneously.
# ABOUTME: Isolates the browser in a virtual display so other windows stay private.

set -euo pipefail

VNC_DISPLAY=":2"
VNC_PORT=5902
GEOMETRY="1920x1080"
PIDFILE="$HOME/.vnc/monitor-session.pids"
HOST_DISPLAY="${DISPLAY:-:0}"

stop_session() {
    echo "Stopping VNC session..."
    if [ -f "$PIDFILE" ]; then
        while IFS= read -r pid; do
            kill "$pid" 2>/dev/null || true
        done < "$PIDFILE"
        rm -f "$PIDFILE"
    fi
    echo "Done."
}

if [ "${1:-}" = "stop" ]; then
    stop_session
    exit 0
elif [ -n "${1:-}" ]; then
    echo "Usage: $0        # start the session"
    echo "       $0 stop   # stop the session"
    exit 1
fi

echo "=== Current displays ==="
gnome-monitor-config list | grep -E 'display-name|CURRENT' || true
echo ""

# Ensure VNC password exists
if [ ! -f "$HOME/.vnc/passwd" ]; then
    echo "No VNC password found. Run 'vncpasswd' first."
    exit 1
fi

# Clean up any previous session
stop_session 2>/dev/null || true

# Start Xvnc (virtual X display with built-in VNC server)
echo "Starting Xvnc on $VNC_DISPLAY ($GEOMETRY)..."
Xvnc "$VNC_DISPLAY" \
    -geometry "$GEOMETRY" \
    -depth 24 \
    -SecurityTypes VncAuth \
    -PasswordFile "$HOME/.vnc/passwd" \
    -AlwaysShared &
XVNC_PID=$!
echo "$XVNC_PID" > "$PIDFILE"
sleep 2

if ! kill -0 "$XVNC_PID" 2>/dev/null; then
    echo "ERROR: Xvnc failed to start. Check ~/.vnc/*.log"
    exit 1
fi

# Start a lightweight window manager on the virtual display
echo "Starting openbox..."
DISPLAY="$VNC_DISPLAY" openbox &
OPENBOX_PID=$!
echo "$OPENBOX_PID" >> "$PIDFILE"
sleep 1

# Enlarge the cursor so it's visible on a projector
echo "Setting large cursor..."
export XCURSOR_SIZE=48

# Launch Firefox on the virtual display, forcing X11 instead of Wayland
echo "Launching Firefox..."
env DISPLAY="$VNC_DISPLAY" WAYLAND_DISPLAY="" GDK_BACKEND=x11 MOZ_ENABLE_WAYLAND=0 XCURSOR_SIZE=48 \
    firefox --new-instance &
FIREFOX_PID=$!
echo "$FIREFOX_PID" >> "$PIDFILE"
sleep 3

# Start two VNC viewers (both connect to the same session)
echo "Starting VNC viewers..."
echo ">>> Move one viewer to the projector and fullscreen it (F8 menu or F11) <<<"
echo ""

env DISPLAY="$HOST_DISPLAY" vncviewer -passwd "$HOME/.vnc/passwd" localhost::$VNC_PORT &
VIEWER1_PID=$!
echo "$VIEWER1_PID" >> "$PIDFILE"

sleep 1

env DISPLAY="$HOST_DISPLAY" vncviewer -passwd "$HOME/.vnc/passwd" localhost::$VNC_PORT &
VIEWER2_PID=$!
echo "$VIEWER2_PID" >> "$PIDFILE"

echo ""
echo "=== VNC session running (Ctrl+C to stop) ==="
echo "  Xvnc:      PID $XVNC_PID"
echo "  Firefox:    PID $FIREFOX_PID"
echo "  Viewers:    PID $VIEWER1_PID, $VIEWER2_PID"
echo ""
echo "To stop:  $0 stop"
echo "Or:       Ctrl+C"

trap stop_session EXIT INT TERM
wait
