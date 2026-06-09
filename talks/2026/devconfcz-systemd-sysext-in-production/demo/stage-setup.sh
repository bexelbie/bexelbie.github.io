#!/bin/bash

set -euo pipefail

TMUX_SESSION="demo"

# --- Presentation environment ---
echo "==> Opening slides in LibreOffice..."
libreoffice --impress "../slides/sysext-slides.pptx" &

echo "==> Opening tmux demo session..."
TMUX_SESSION="demo"
ptyxis --new-window -- tmux new-session -s "${TMUX_SESSION}"
sleep 2
ptyxis --new-window -- tmux attach-session -t "${TMUX_SESSION}"

echo ""
echo "==> Run monitor-setup.sh manually in a separate terminal:"
echo "    $./monitor-setup.sh"
