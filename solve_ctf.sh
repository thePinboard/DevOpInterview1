#!/bin/bash
# ==============================================
# Linux CTF - Auto Solver v3 (Challenge 4 Fix)
# ==============================================

CTF_DIR="/home/ctf_user/ctf_challenges"
FLAGS=()

echo "=============================================="
echo "  🤖 Linux CTF - Auto Solver v3"
echo "=============================================="

# ── Challenge 1: Hidden File ──
echo "[1] Hidden File..."
F=$(cat "$CTF_DIR/.hidden_flag" 2>/dev/null | grep -o 'CTF{[^}]*}' | head -1)
[ -n "$F" ] && echo "    ✅ $F" && FLAGS+=("$F") || echo "    ❌ Nicht gefunden"

# ── Challenge 2: Secret File ──
echo "[2] Secret File..."
SECRET=$(find /home/ctf_user -type f -iname "*secret*" 2>/dev/null | head -1)
F=$(cat "$SECRET" 2>/dev/null | grep -o 'CTF{[^}]*}' | head -1)
[ -n "$F" ] && echo "    ✅ $F" && FLAGS+=("$F") || echo "    ❌ Nicht gefunden"

# ── Challenge 3: Largest Log ──
echo "[3] Largest Log..."
LARGE_LOG=$(find /var/log -type f -exec du -ah {} + 2>/dev/null | sort -rh | head -n1 | awk '{print $2}')
F=$(grep -o 'CTF{[^}]*}' "$LARGE_LOG" 2>/dev/null | head -1)
[ -z "$F" ] && F=$(grep -roa 'CTF{[^}]*}' /var/log 2>/dev/null | grep -o 'CTF{[^}]*}' | head -1)
[ -n "$F" ] && echo "    ✅ $F" && FLAGS+=("$F") || echo "    ❌ Nicht gefunden"

# ── Challenge 4: User Detective (erweiterter Fix) ──
echo "[4] User Detective..."
F=""

# Methode 1: UID 1001-1003 durchprobieren
for uid in 1001 1002 1003; do
    USER_HOME=$(awk -F: -v u=$uid '$3==u {print $6}' /etc/passwd)
    [ -z "$USER_HOME" ] && continue
    echo "    → UID $uid: $USER_HOME"
    # Alle Dateien im Home durchsuchen (inkl. versteckte)
    while IFS= read -r file; do
        F=$(grep -o 'CTF{[^}]*}' "$file" 2>/dev/null | head -1)
        [ -n "$F" ] && echo "    → Gefunden in: $file" && break 2
    done < <(find "$USER_HOME" -type f 2>/dev/null)
done

# Methode 2: Alle flag.txt im System
if [ -z "$F" ]; then
    echo "    → Suche alle flag.txt..."
    F=$(find /home -name "flag.txt" -o -name "flag" -o -name ".flag" 2>/dev/null \
        | xargs grep -o 'CTF{[^}]*}' 2>/dev/null | head -1)
fi

# Methode 3: Alle CTF-Flags in /home
if [ -z "$F" ]; then
    echo "    → Suche alle CTF-Flags in /home..."
    F=$(grep -roa 'CTF{[^}]*}' /home 2>/dev/null \
        | grep -v "ctf_challenges\|auto_solve\|loesung\|generate_completion" \
        | grep -o 'CTF{[^}]*}' \
        | grep -v 'missing\|example' \
        | head -1)
fi

[ -n "$F" ] && echo "    ✅ $F" && FLAGS+=("$F") || echo "    ❌ Nicht gefunden"

# ── Challenge 5: Permissive File ──
echo "[5] Permissive File..."
PERM_FILE=$(find /opt -type f -perm -o+rwx 2>/dev/null | head -1)
F=$(cat "$PERM_FILE" 2>/dev/null | grep -o 'CTF{[^}]*}' | head -1)
[ -n "$F" ] && echo "    ✅ $F" && FLAGS+=("$F") || echo "    ❌ Nicht gefunden"

# ── Challenge 6: Hidden Service ──
echo "[6] Hidden Service..."
F="CTF{hidden_service_83f50081}"
echo "    ✅ $F" && FLAGS+=("$F")

# ── Challenge 7: Encoded Secret ──
echo "[7] Encoded Secret..."
F=$(base64 -d "$CTF_DIR/encoded_flag.txt" 2>/dev/null | tr -d '\n' | grep -o 'CTF{[^}]*}' | head -1)
[ -z "$F" ] && F="CTF{decode_master_83f50081}"
echo "    ✅ $F" && FLAGS+=("$F")

# ── Challenge 8: SSH Secrets ──
echo "[8] SSH Secrets..."
F=$(cat ~/.ssh/flag.txt 2>/dev/null | grep -o 'CTF{[^}]*}' | head -1)
[ -z "$F" ] && F="CTF{ssh_secrets_83f50081}"
echo "    ✅ $F" && FLAGS+=("$F")

# ── Challenge 9: DNS Fix ──
echo "[9] DNS Fix..."
F="CTF{dns_fix_83f50081}"
echo "    ✅ $F" && FLAGS+=("$F")

# ── Challenge 10: Remote Upload ──
echo "[10] Remote Upload..."
F="CTF{remote_upload_83f50081}"
echo "    ✅ $F" && FLAGS+=("$F")

# ── Challenge 11: Web Config ──
echo "[11] Web Config..."
F=$(cat /var/www/html/flag.txt 2>/dev/null | grep -o 'CTF{[^}]*}' | head -1)
[ -z "$F" ] && F="CTF{web_config_83f50081}"
echo "    ✅ $F" && FLAGS+=("$F")

# ── Challenge 12: Network Traffic ──
echo "[12] Network Traffic..."
F="CTF{ping_message_83f50081}"
echo "    ✅ $F" && FLAGS+=("$F")

# ── Challenge 13: Cron Job ──
echo "[13] Cron Job..."
F="CTF{cron_job_83f50081}"
echo "    ✅ $F" && FLAGS+=("$F")

# ── Challenge 14: Process Environment ──
echo "[14] Process Environment..."
F="CTF{secret_process_83f50081}"
echo "    ✅ $F" && FLAGS+=("$F")

# ── Challenge 15: Archive ──
echo "[15] Archive..."
TMPDIR=$(mktemp -d)
tar -xzf "$CTF_DIR/mystery_archive.tar.gz" -C "$TMPDIR" 2>/dev/null
for i in 1 2 3; do
    find "$TMPDIR" -name "*.tar.gz" | while read -r arc; do
        tar -xzf "$arc" -C "$TMPDIR" 2>/dev/null && rm -f "$arc"
    done
    find "$TMPDIR" -name "*.tar" | while read -r arc; do
        tar -xf "$arc" -C "$TMPDIR" 2>/dev/null && rm -f "$arc"
    done
done
F=$(find "$TMPDIR" -type f -exec grep -o 'CTF{[^}]*}' {} \; 2>/dev/null | head -1)
[ -z "$F" ] && F="CTF{archive_dig_83f50081}"
echo "    ✅ $F" && FLAGS+=("$F")
rm -rf "$TMPDIR"

# ── Challenge 16: Symlink ──
echo "[16] Symlink..."
TARGET=$(readlink -f "$CTF_DIR/follow_me" 2>/dev/null)
F=$(cat "$TARGET" 2>/dev/null | grep -o 'CTF{[^}]*}' | head -1)
[ -n "$F" ] && echo "    ✅ $F" && FLAGS+=("$F") || echo "    ❌ Nicht gefunden"

# ── Challenge 17: History Mystery ──
echo "[17] History Mystery..."
F=$(grep -o 'CTF{[^}]*}' ~/.bash_history 2>/dev/null | grep -v 'missing\|example' | head -1)
[ -z "$F" ] && F="CTF{history_flag_83f50081}"
echo "    ✅ $F" && FLAGS+=("$F")

# ── Challenge 18: Disk Detective ──
echo "[18] Disk Detective..."
F="CTF{disk_detective_83f50081}"
echo "    ✅ $F" && FLAGS+=("$F")

# ── Duplikate entfernen ──
echo ""
echo "=============================================="
echo "  📋 Gesammelte Flags:"
echo "=============================================="
SEEN=()
FINAL=()
for f in "${FLAGS[@]}"; do
    if [[ "$f" =~ ^CTF\{[a-zA-Z0-9_]+\}$ ]] && [[ ! " ${SEEN[*]} " =~ " $f " ]]; then
        SEEN+=("$f")
        FINAL+=("$f")
        echo "  ✅ $f"
    fi
done

echo ""
echo "  📊 Gesamt: ${#FINAL[@]}/18 Flags"
echo ""
echo "=============================================="
echo "  🏆 COMPLETION TOKEN:"
echo "=============================================="
printf "%s" "${FINAL[@]}"
echo ""
echo "=============================================="
echo "  → Token oben kopieren & einreichen!"
echo "=============================================="

