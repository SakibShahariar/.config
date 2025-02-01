#!/bin/bash

# Check dependencies
if ! command -v yad &>/dev/null || ! command -v zenity &>/dev/null; then
    yad --error --width=400 \
        --text="Required packages:\n- yad\n- zenity\n\nInstall with:\n'sudo apt install yad zenity'"
    exit 1
fi

# Temporary files
ERROR_LOG=$(mktemp)
PROGRESS_LOG=$(mktemp)
CONFLICT_LOG=$(mktemp)
trap 'rm -f "$ERROR_LOG" "$PROGRESS_LOG" "$CONFLICT_LOG"' EXIT

# Performance configuration
MAX_PARALLEL_JOBS=$(( $(nproc) * 2 ))
declare -i TOTAL COPIED=0 SKIPPED=0 ERRORS=0

# ---------------------------
# Zenity Progress Monitoring
# ---------------------------
update_progress() {
    while sleep 0.5; do
        processed=$((COPIED + SKIPPED + ERRORS))
        if (( TOTAL > 0 )); then
            percent=$(( processed * 100 / TOTAL ))
            echo "$percent"
            echo "# Processed: $processed/$TOTAL | Copied: $COPIED | Errors: $ERRORS"
        fi
        (( processed >= TOTAL )) && break
    done
}

# ---------------------------
# Silent Copy Function
# ---------------------------
parallel_copy() {
    local src=$1 dest=$2
    rsync -ah --quiet "$src" "$dest" 2>> "$ERROR_LOG" && return 0 || return 1
}

# ---------------------------
# Main Execution
# ---------------------------
{
    # File selection with YAD
    ITEMS=$(yad --file --multiple --separator="|" \
        --title="📂 Select Items to Copy" \
        --width=800 --height=500 \
        --add-preview \
        --filename="$HOME/") || exit 1

    [ -z "$ITEMS" ] && { yad --error --text="No items selected!"; exit 1; }
    IFS="|" read -ra ITEM_ARRAY <<< "$ITEMS"
    TOTAL=${#ITEM_ARRAY[@]}
    (( TOTAL == 0 )) && { yad --error --text="No valid items selected!"; exit 1; }

    # Destination handling with YAD
    DEST=$(yad --file --directory \
        --title="📁 Select Destination" \
        --width=600 --height=400 \
        --filename="$HOME/") || exit 1

    [ -z "$DEST" ] && { yad --error --text="No destination selected!"; exit 1; }

    # Path sanitization
    DEST=$(echo "$DEST" | sed -e '
        s/^file:\/\///;
        s/%20/ /g;
        s/[\\\r\n]//g;
        s/\/\+/\//g;
        s/[[:space:]]*$//;
    ')
    DEST="${DEST/#~/$HOME}"
    DEST="${DEST%/}"

    # Validation
    [[ "$DEST" =~ ^/ ]] || { yad --error --text="Invalid destination path!\n'$DEST'"; exit 1; }

    # Directory creation
    if [ ! -d "$DEST" ]; then
        yad --question --text="Create new directory?\n$DEST" \
            --button="Cancel:1" --button="Create:0" || exit 1
        mkdir -p "$DEST" 2>> "$ERROR_LOG" || { yad --error --text="Failed to create directory!"; exit 1; }
    fi

    # Pre-process conflicts
    declare -a conflict_files
    for src in "${ITEM_ARRAY[@]}"; do
        name=$(basename -- "$src")
        dest="$DEST/$name"
        [ -e "$dest" ] && conflict_files+=("$name")
    done

    # Bulk conflict resolution with YAD
    if [ ${#conflict_files[@]} -gt 0 ]; then
        yad --list --checklist \
            --title="Conflict Resolution" \
            --text="Select files to overwrite:" \
            --column="Overwrite" --column="File" \
            $(printf 'FALSE "%s"\n' "${conflict_files[@]}") > "$CONFLICT_LOG"
    fi

    # Start Zenity progress monitor
    (
        update_progress
    ) | zenity --progress \
        --title="Copying Files" \
        --percentage=0 \
        --auto-close \
        --no-cancel \
        --width=400

    # Main copy process
    for src in "${ITEM_ARRAY[@]}"; do
        name=$(basename -- "$src")
        dest="$DEST/$name"

        # Skip conflicts not selected
        if [ -e "$dest" ] && ! grep -qxF "$name" "$CONFLICT_LOG"; then
            ((SKIPPED++))
            continue
        fi

        # Parallel copy with resource limits
        if [ -w "$DEST" ]; then
            parallel_copy "$src" "$dest" &
        else
            pkexec bash -c "$(declare -f parallel_copy); parallel_copy '$src' '$dest'" &
        fi

        # Track results
        if wait $!; then
            ((COPIED++))
        else
            ((ERRORS++))
        fi

        # Limit parallel jobs
        while (( $(jobs -rp | wc -l) >= MAX_PARALLEL_JOBS )); do sleep 0.1; done
    done

    # Final report
    yad --info --title="Copy Complete" \
        --text="Operation completed!\n\nCopied: $COPIED\nSkipped: $SKIPPED\nErrors: $ERRORS"
    [ -s "$ERROR_LOG" ] && yad --text-info --title="Copy Errors" --filename="$ERROR_LOG"

} 2>&1 | grep -v "WARNING: gnome-keyring:: couldn't connect to:"
