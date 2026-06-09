#!/bin/sh
# Show the live backup tmux session if one is running; otherwise show recent log
# and wait for one to appear. Read-only attach (-r).
SOCK=/sock/backup.sock
SESSION=homelab-backup
while true; do
  if tmux -S "$SOCK" has-session -t "$SESSION" 2>/dev/null; then
    tmux -S "$SOCK" attach -r -t "$SESSION"
  else
    clear
    echo "  ┌──────────────────────────────────────────┐"
    echo "  │   Homelab Backup Console                  │"
    echo "  └──────────────────────────────────────────┘"
    echo
    echo "  No backup is running right now. (Scheduled daily at 02:45.)"
    echo "  A live view will appear automatically when a backup starts."
    echo
    echo "  ── Recent activity ─────────────────────────"
    tail -n 40 /backup.log 2>/dev/null || echo "  (no log yet)"
    sleep 5
  fi
done
