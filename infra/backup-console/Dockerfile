# Web terminal that attaches (read-only) to the host's `homelab-backup` tmux session
# so the live restic progress can be watched from the browser (linked off Homepage).
#
# tmux's client and server must share a protocol version, so this image's tmux must
# match the HOST's tmux. Host = 3.4 → Alpine 3.20 (tmux 3.4). If you upgrade host
# tmux, rebuild from the matching Alpine.
FROM alpine:3.20
RUN apk add --no-cache ttyd tmux
COPY console.sh /usr/local/bin/console.sh
RUN chmod +x /usr/local/bin/console.sh
EXPOSE 7681
# No -W → read-only terminal (viewers can watch but not type).
ENTRYPOINT ["ttyd", "-p", "7681", "-t", "titleFixed=Homelab Backup", \
            "-t", "fontSize=14", "-t", "disableLeaveAlert=true", \
            "/usr/local/bin/console.sh"]
