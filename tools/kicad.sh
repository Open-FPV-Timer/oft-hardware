#!/usr/bin/env bash
# Run a command inside the official KiCad 9 container with this repo mounted at /work.
#   tools/kicad.sh gen/build.sh 4            (4-Node board: regenerate + ERC + DRC + previews)
#   tools/kicad.sh gen/build.sh 4 check      (ERC + DRC + previews only)
#   tools/kicad.sh kicad-cli sch erc carrier-4/oft-carrier-4.kicad_sch
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec docker run --rm -u "$(id -u):$(id -g)" -e HOME=/tmp \
    -v "${ROOT}:/work" -w /work "${KICAD_IMAGE:-kicad/kicad:9.0}" "$@"
