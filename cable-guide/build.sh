#!/usr/bin/env bash
# Export the STL and a picture into out/, using the official OpenSCAD container.
#   ./build.sh [-D 'name=value' ...]      e.g. -D cable_d=5.5
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "${HERE}/out"
scad() {
    docker run --rm -u "$(id -u):$(id -g)" -e HOME=/tmp -v "${HERE}:/work" -w /work \
        "${OPENSCAD_IMAGE:-openscad/openscad:dev}" openscad --backend=manifold "$@" 2>&1 | grep -v '^$' || true
}
scad "$@" -o out/cable-guide.stl guide.scad
scad -q "$@" --imgsize=1200,900 --colorscheme=Tomorrow --render --viewall --autocenter \
    --camera=0,0,0,35,0,20,0 -o out/cable-guide.png guide.scad
scad -q "$@" --imgsize=1200,900 --colorscheme=Tomorrow --render --viewall --autocenter \
    --projection=o --camera=0,0,0,0,0,0,0 -o out/cable-guide-top.png guide.scad
