#!/usr/bin/env bash
# Build portable Python embeddable environments and pack each one as a zip.
# Usage: bash build.sh
set -euo pipefail

# Latest patch release of every supported minor version.
PY_VERSIONS=(3.12.14 3.13.15 3.14.7)

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf '[build] %s\n' "$*"; }
die() { printf '[build][ERROR] %s\n' "$*" >&2; exit 1; }

for c in curl unzip zip sed; do
    command -v "$c" >/dev/null || die "missing: $c"
done

[[ -f "$BASE/script.json" ]] || die "template script.json not found"

# Each release is staged in .build/<tag>/ so the generated script.json ends up
# at the archive root, as a sibling of externals/.
build() {
    local ver="$1"
    local tag="${ver%.*}"
    tag="${tag//./}"

    local work="$BASE/.build/$tag"
    local ext="$work/externals"
    local name="mpv-python${tag}"
    local out="$BASE/${name}.zip"
    local url="https://github.com/ahaoboy/mpv-vapoursynth/releases/latest/download/${name}.zip"

    log "=== Python $ver (${name}) ==="
    rm -rf "$work"
    mkdir -p "$ext"

    # 1. Python embeddable
    log "Downloading Python $ver ..."
    local zip="python-${ver}-embed-amd64.zip"
    curl -fSL -o "$BASE/$zip" "https://www.python.org/ftp/python/${ver}/${zip}"
    unzip -oq "$BASE/$zip" -d "$ext"
    rm -f "$BASE/$zip"

    # 2. Enable site + site-packages (append to existing _pth)
    printf 'Lib\\site-packages\n\nimport site\n' >> "$ext"/python*._pth

    local py="$ext/python.exe"
    [[ -f "$py" ]] || die "python.exe not found"

    # 3. pip
    log "Installing pip ..."
    curl -fSL -o "$BASE/get-pip.py" https://bootstrap.pypa.io/get-pip.py
    "$py" "$BASE/get-pip.py" --no-warn-script-location
    rm -f "$BASE/get-pip.py"

    # 4. Grayscale test script
    if [[ -f "$BASE/test.py" ]]; then
        cp "$BASE/test.py" "$ext/test.py"
    fi

    # 5. Trim unneeded files before packing
    #    - Scripts/: pip-generated CLI launchers, not needed at runtime
    #    - __pycache__/: bytecode caches, regenerated automatically
    log "Trimming unneeded files ..."
    rm -rf "$ext/Scripts"
    find "$ext" -name "__pycache__" -type d -prune -exec rm -rf {} +

    # 6. Generate script.json from the template (name + download follow this build)
    log "Generating script.json (name: ${name}) ..."
    sed -e "s|\"name\": \".*\"|\"name\": \"$name\"|" \
        -e "s|\"download\": \".*\"|\"download\": \"$url\"|" \
        "$BASE/script.json" > "$work/script.json"
    grep -q "\"name\": \"$name\"" "$work/script.json" ||
        die "template script.json has no name field to replace"

    # 7. Pack (script.json, mpv.conf and externals/ as sibling top-level entries)
    local items=(script.json externals)
    if [[ -f "$BASE/mpv.conf" ]]; then
        cp "$BASE/mpv.conf" "$work/mpv.conf"
        items+=(mpv.conf)
    fi

    log "Packing $(basename "$out") ..."
    rm -f "$out"
    ( cd "$work" && zip -rq "$out" "${items[@]}" )
}

for ver in "${PY_VERSIONS[@]}"; do
    build "$ver"
done

log "Done: $(printf '%s ' "$BASE"/mpv-python*.zip)"
