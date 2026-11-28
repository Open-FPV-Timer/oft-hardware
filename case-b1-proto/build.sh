#!/usr/bin/env bash
# Export the STLs and preview images into out/, using the official OpenSCAD container.
#   ./build.sh [-D 'name=value' ...]      extra arguments go to every openscad call
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="${OUT:-out}"
mkdir -p "${HERE}/${OUT}"
scad() {
    docker run --rm -u "$(id -u):$(id -g)" -e HOME=/tmp -v "${HERE}:/work" -w /work \
        "${OPENSCAD_IMAGE:-openscad/openscad:dev}" openscad --backend=manifold -q "$@"
}
IMG=(--imgsize=1600,1100 --colorscheme=Tomorrow --render)

# name, then the settings that make it
parts=(
    "body|part=\"body\""
    "lid|part=\"lid\""
    "base-flat|part=\"base-flat\""
    "base-pvc-half-inch|part=\"base-pvc\";pipe=\"1/2\""
    "base-pvc-three-quarter-inch|part=\"base-pvc\";pipe=\"3/4\""
    "base-strap|part=\"base-strap\""
)
for entry in "${parts[@]}"; do
    name="${entry%%|*}"
    scad "$@" -D "${entry#*|}" -o "${OUT}/${name}.stl" case.scad
    scad "$@" -D "${entry#*|}" "${IMG[@]}" --viewall --autocenter -o "${OUT}/part-${name}.png" case.scad
done

C=25,25,8   # camera: look-at x,y,z then rotation x,y,z then distance
scad "$@" "${IMG[@]}" --camera=$C,60,0,35,360 -o "${OUT}/assembly.png" case.scad
scad "$@" "${IMG[@]}" --camera=$C,60,0,35,360 -D show_lid=false -o "${OUT}/assembly-open.png" case.scad
scad "$@" "${IMG[@]}" --camera=$C,60,0,35,440 -D explode=30 -o "${OUT}/exploded.png" case.scad
scad "$@" "${IMG[@]}" --camera=$C,120,0,215,360 -o "${OUT}/assembly-pipe-side.png" case.scad
scad "$@" "${IMG[@]}" --camera=$C,60,0,35,360 -D 'base="flat"' -o "${OUT}/assembly-flat.png" case.scad
scad "$@" "${IMG[@]}" --camera=$C,120,0,215,360 -D 'base="strap"' -o "${OUT}/assembly-strap.png" case.scad
scad "$@" "${IMG[@]}" --camera=$C,90,0,90,280 --projection=o -o "${OUT}/end-usb.png" case.scad
scad "$@" "${IMG[@]}" --camera=$C,90,0,90,280 --projection=o -D 'base="strap"' -o "${OUT}/end-strap.png" case.scad
scad "$@" "${IMG[@]}" --camera=$C,90,0,270,280 --projection=o -o "${OUT}/end-ethernet.png" case.scad
scad "$@" "${IMG[@]}" --camera=$C,90,0,0,360 --projection=o -o "${OUT}/side.png" case.scad
scad "$@" "${IMG[@]}" --camera=$C,0,0,0,360 --projection=o -D show_lid=false -D 'base="none"' -o "${OUT}/top-open.png" case.scad

# interference checks: each pair must share less than 0.5 mm3
checks=(
    "body-lid|check_n=0"
    "case-electronics|check_n=1"
    "case-usbplugs|check_n=2"
    "case-base-flat|check_n=3;base=\"flat\""
    "case-base-pvc|check_n=3;base=\"pvc\""
    "case-base-strap|check_n=3;base=\"strap\""
    "clip-pipe-half-inch|check_n=4;pipe=\"1/2\""
    "clip-pipe-three-quarter-inch|check_n=4;pipe=\"3/4\""
)
fail=0
for entry in "${checks[@]}"; do
    rm -f "${HERE}/${OUT}/.check.stl"
    scad "$@" -D 'part="check"' -D "${entry#*|}" --export-format=binstl -o "${OUT}/.check.stl" case.scad 2>/dev/null || true
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
    echo "check ${entry%%|*}: ${vol} mm3"
    python3 -c "import sys; sys.exit(0 if float('$vol') >= 0.5 else 1)" && fail=1
done
rm -f "${HERE}/${OUT}/.check.stl"
for p in 1/2 3/4; do
    docker run --rm -v "${HERE}:/work" -w /work "${OPENSCAD_IMAGE:-openscad/openscad:dev}" openscad -D "pipe=\"$p\"" -o /tmp/x.stl case.scad 2>&1 | grep ECHO || true
done
[ "$fail" = 0 ] && echo "interference checks: all clear" || echo "INTERFERENCE FOUND"
exit $fail
