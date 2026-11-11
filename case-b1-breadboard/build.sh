#!/usr/bin/env bash
# Export the STLs and preview images into out/, using the official OpenSCAD container.
# Nothing is installed on the host.
#   ./build.sh                      default (full-size breadboard)
#   ./build.sh -D 'bb_preset="half"'   any extra arguments go to every openscad call
#   OUT=out-half ./build.sh -D 'bb_preset="half"'
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="${OUT:-out}"
mkdir -p "${HERE}/${OUT}"
scad() {
    docker run --rm -u "$(id -u):$(id -g)" -e HOME=/tmp -v "${HERE}:/work" -w /work \
        "${OPENSCAD_IMAGE:-openscad/openscad:dev}" openscad --backend=manifold -q "$@"
}
IMG=(--imgsize=1600,1100 --colorscheme=Tomorrow --render)

for p in base lid hatch bulkhead clip; do
    scad "$@" -D "part=\"$p\"" -o "${OUT}/$p.stl" case.scad
    scad "$@" -D "part=\"$p\"" "${IMG[@]}" --viewall --autocenter -o "${OUT}/part-$p.png" case.scad
done

# assembled views (camera: look-at x,y,z, rotation x,y,z, distance)
C=98,0,8
scad "$@" "${IMG[@]}" --camera=$C,60,0,35,420 -o "${OUT}/assembly.png" case.scad
scad "$@" "${IMG[@]}" --camera=$C,55,0,35,420 -D show_lid=false -o "${OUT}/assembly-open.png" case.scad
scad "$@" "${IMG[@]}" --camera=$C,0,0,0,560 --projection=o -D show_lid=false -o "${OUT}/top-open.png" case.scad
scad "$@" "${IMG[@]}" --camera=$C,0,0,0,560 --projection=o -o "${OUT}/top.png" case.scad
scad "$@" "${IMG[@]}" --camera=$C,90,0,270,150 --projection=o -o "${OUT}/end-ethernet.png" case.scad
scad "$@" "${IMG[@]}" --camera=$C,90,0,90,150 --projection=o -o "${OUT}/end-antenna.png" case.scad
scad "$@" "${IMG[@]}" --camera=$C,90,0,0,560 --projection=o -o "${OUT}/side.png" case.scad
scad "$@" "${IMG[@]}" --camera=$C,125,0,35,420 -o "${OUT}/assembly-below.png" case.scad
scad "$@" "${IMG[@]}" --camera=$C,60,0,35,520 -D explode=35 -o "${OUT}/exploded.png" case.scad
scad "$@" "${IMG[@]}" --camera=$C,125,0,125,420 -D 'pipe_dir="across"' -o "${OUT}/assembly-across.png" case.scad

# interference checks: every pair must share less than 0.5 mm3 (touching faces export as
# zero-volume shells, so the volume is measured rather than testing for an empty result)
names=(base-lid base-hatch lid-hatch base-bulkhead lid-bulkhead base-clips case-electronics case-usbplug clips-pipe base-pipe)
fail=0
for n in "${!names[@]}"; do
    for dir in along across; do
        rm -f "${HERE}/${OUT}/.check.stl"
        scad "$@" -D 'part="check"' -D "check_n=$n" -D "pipe_dir=\"$dir\"" --export-format=binstl -o "${OUT}/.check.stl" case.scad 2>/dev/null || true
        vol=$(python3 - "${HERE}/${OUT}/.check.stl" <<'PY'
import os, struct, sys
f = sys.argv[1]
vol = 0.0
if os.path.exists(f):
    b = open(f, "rb").read()
    for i in range(struct.unpack("<I", b[80:84])[0]):
        a, p, c = (struct.unpack("<3f", b[96 + i * 50 + k * 12:108 + i * 50 + k * 12]) for k in range(3))
        vol += (a[0] * (p[1] * c[2] - p[2] * c[1]) - a[1] * (p[0] * c[2] - p[2] * c[0]) + a[2] * (p[0] * c[1] - p[1] * c[0])) / 6
print(f"{abs(vol):.2f}")
PY
)
        if python3 -c "import sys; sys.exit(0 if float('$vol') >= 0.5 else 1)"; then
            echo "INTERFERENCE: ${names[$n]} (pipe $dir): $vol mm3"; fail=1
        fi
    done
done
rm -f "${HERE}/${OUT}/.check.stl"
[ "$fail" = 0 ] && echo "interference checks: all clear"
scad_echo() { docker run --rm -v "${HERE}:/work" -w /work "${OPENSCAD_IMAGE:-openscad/openscad:dev}" openscad "$@" 2>&1 | grep ECHO || true; }
scad_echo "$@" -D 'part="clip"' -o /tmp/x.stl case.scad
exit $fail
