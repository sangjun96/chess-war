#!/usr/bin/env sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
web_dir="$project_dir/web"
output_dir="$project_dir/dist"

if command -v uuidgen >/dev/null 2>&1; then
    build_id=$(uuidgen | tr '[:upper:]' '[:lower:]')
else
    build_id="$(date +%s)-$$"
fi
game_archive="chess-war-$build_id.love"

for runtime_file in player.js style.css 11.5/love.js 11.5/love.wasm lua/normalize1.lua lua/normalize2.lua; do
    if [ ! -f "$web_dir/$runtime_file" ]; then
        echo "Missing love.js runtime file: web/$runtime_file" >&2
        exit 1
    fi
done

rm -rf "$output_dir"
mkdir -p "$output_dir"
cp -R "$web_dir/." "$output_dir/"
sed "s/__GAME_ARCHIVE__/$game_archive/g" "$web_dir/index.html" > "$output_dir/index.html"

(
    cd "$project_dir"
    zip -q -r "$output_dir/$game_archive" ./*.lua assets skill_definitions
)

echo "Web build created: $output_dir ($game_archive)"
