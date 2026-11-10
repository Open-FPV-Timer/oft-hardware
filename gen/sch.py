"""Schematic writer shared by the board generators.

Builds a .kicad_sch from the KiCad stock symbol libraries plus module symbols made here.
Coordinates are in schematic grid units (1 unit = 1.27 mm) so everything stays on grid.
Run inside the kicad/kicad:9.0 container (see tools/kicad.sh).
"""
import copy
import os
import uuid

from sexpr import Q, parse, dump, find, first

SYMDIR = "/usr/share/kicad/symbols"
U = 1.27
LIBDIR = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))

R0603 = "Resistor_SMD:R_0603_1608Metric"
C0603 = "Capacitor_SMD:C_0603_1608Metric"
C0805 = "Capacitor_SMD:C_0805_2012Metric"


def mm(v):
    return ("%.4f" % (v * U)).rstrip("0").rstrip(".")


def effects(justify=None, hide=False, size=1.27):
    e = ["effects", ["font", ["size", str(size), str(size)]]]
    if justify:
        e.append(["justify"] + justify.split())
    if hide:
        e.append(["hide", "yes"])
    return e


def rot(dx, dy, angle):
    for _ in range((angle // 90) % 4):  # KiCad rotates counter-clockwise on screen
        dx, dy = dy, -dx
    return dx, dy


class Sheet:
    def __init__(self, project, out_dir, namespace):
        self.project = project
        self.out_dir = out_dir
        self.ns = uuid.UUID(namespace)
        self.n = 0
        self.root = Q(str(uuid.uuid5(self.ns, "root")))
        self.libs = {}
        self.lib_symbols = {}
        self.custom = []
        self.items = []
        self.placed = {}
        self.pwr = 0

    def uid(self, tag=""):
        self.n += 1
        return Q(str(uuid.uuid5(self.ns, "%s-%d" % (tag, self.n))))

    # ------------------------------------------------------------ symbols
    def load_symbol(self, lib_id):
        if lib_id in self.lib_symbols:
            return self.lib_symbols[lib_id]
        lib, name = lib_id.split(":")
        if lib not in self.libs:
            self.libs[lib] = parse(open("%s/%s.kicad_sym" % (SYMDIR, lib)).read())
        by_name = {s[1]: s for s in find(self.libs[lib], "symbol")}
        sym = copy.deepcopy(by_name[name])
        ext = first(sym, "extends")
        if ext:  # flatten derived symbols: parent graphics, child properties
            parent = copy.deepcopy(by_name[ext[1]])
            props = find(sym, "property")
            body = [c for c in parent[2:] if not (isinstance(c, list) and c[0] == "property")]
            for c in body:
                if isinstance(c, list) and c[0] == "symbol":
                    c[1] = Q(c[1].replace(ext[1], name, 1))
            split = next(i for i, c in enumerate(body) if isinstance(c, list) and c[0] == "symbol")
            sym = ["symbol", Q(name)] + body[:split] + props + body[split:]
        sym[1] = Q(lib_id)
        self.lib_symbols[lib_id] = sym
        return sym

    def module_symbol(self, name, left, right, footprint, description, half_width=9):
        """A box symbol in the project library 'oft'. left/right: [(pin number, pin name)], top
        to bottom. All pins are passive: these are whole modules, not chips."""
        rows = max(len(left), len(right))
        top = rows - 1                                  # pins 2 units apart, centred on the origin
        hw = half_width * U

        def prop(key, value, y, hide):
            return ["property", Q(key), Q(value), ["at", "0", "%.2f" % y, "0"], effects(hide=hide)]

        def pins(side, plist):
            out = []
            for i, (num, pname) in enumerate(plist):
                x = (-(half_width + 2) if side == "l" else (half_width + 2)) * U
                out.append(["pin", "passive", "line", ["at", "%.2f" % x, "%.2f" % ((top - 2 * i) * U),
                                                       "0" if side == "l" else "180"],
                            ["length", "2.54"], ["name", Q(pname), effects()], ["number", Q(str(num)), effects()]])
            return out

        sym = ["symbol", Q("oft:" + name), ["exclude_from_sim", "no"], ["in_bom", "yes"], ["on_board", "yes"],
               prop("Reference", "U", (top + 3) * U, False), prop("Value", name, -(top + 3) * U, False),
               prop("Footprint", footprint, 0, True), prop("Datasheet", "", 0, True),
               prop("Description", description, 0, True),
               ["symbol", Q(name + "_0_1"),
                ["rectangle", ["start", "%.2f" % -hw, "%.2f" % ((top + 2) * U)], ["end", "%.2f" % hw, "%.2f" % (-(top + 2) * U)],
                 ["stroke", ["width", "0.254"], ["type", "default"]], ["fill", ["type", "background"]]]],
               ["symbol", Q(name + "_1_1")] + pins("l", left) + pins("r", right),
               ["embedded_fonts", "no"]]
        self.lib_symbols["oft:" + name] = sym
        lib = copy.deepcopy(sym)
        lib[1] = Q(name)
        self.custom.append(lib)

    def pin_table(self, sym):
        pins = {}
        for unit in find(sym, "symbol"):
            for p in find(unit, "pin"):
                at = first(p, "at")
                pins[str(first(p, "number")[1])] = (float(at[1]) / U, float(at[2]) / U)
        return pins

    # ------------------------------------------------------------ sheet items
    def place(self, lib_id, ref, value, x, y, angle=0, footprint="", ref_at=None, val_at=None,
              fields=None, bom=True, board=True, just="left"):
        sym = self.load_symbol(lib_id)
        pins = self.pin_table(sym)
        power = lib_id.startswith("power:")
        ref_at = ref_at or (2, -1)
        val_at = val_at or (2, 1)
        fa = "90" if (angle % 180 == 90 and not power) else "0"
        node = ["symbol", ["lib_id", Q(lib_id)], ["at", mm(x), mm(y), str(angle)], ["unit", "1"],
                ["exclude_from_sim", "no"], ["in_bom", "yes" if bom else "no"],
                ["on_board", "yes" if board else "no"], ["dnp", "no"], ["uuid", self.uid(ref)],
                ["property", Q("Reference"), Q(ref), ["at", mm(x + ref_at[0]), mm(y + ref_at[1]), fa],
                 effects(just, hide=power)],
                ["property", Q("Value"), Q(value), ["at", mm(x + val_at[0]), mm(y + val_at[1]), fa],
                 effects("" if power else just, hide=(value == "PWR_FLAG"))],
                ["property", Q("Footprint"), Q(footprint), ["at", mm(x), mm(y), "0"], effects(hide=True)],
                ["property", Q("Datasheet"), Q(""), ["at", mm(x), mm(y), "0"], effects(hide=True)],
                ["property", Q("Description"), Q(""), ["at", mm(x), mm(y), "0"], effects(hide=True)]]
        for k, v in (fields or {}).items():
            node.append(["property", Q(k), Q(v), ["at", mm(x), mm(y), "0"], effects(hide=True)])
        for num in pins:
            node.append(["pin", Q(num), ["uuid", self.uid(ref + num)]])
        node.append(["instances", ["project", Q(self.project),
                                   ["path", Q("/" + self.root), ["reference", Q(ref)], ["unit", "1"]]]])
        self.items.append(node)
        self.placed[ref] = (x, y, angle, pins)

    def pin(self, ref, num):
        x, y, angle, pins = self.placed[ref]
        px, py = pins[str(num)]
        dx, dy = rot(px, -py, angle)
        return (x + dx, y + dy)

    def wire(self, *pts):
        for a, b in zip(pts, pts[1:]):
            self.items.append(["wire", ["pts", ["xy", mm(a[0]), mm(a[1])], ["xy", mm(b[0]), mm(b[1])]],
                               ["stroke", ["width", "0"], ["type", "default"]], ["uuid", self.uid("w")]])

    def junction(self, x, y):
        self.items.append(["junction", ["at", mm(x), mm(y)], ["diameter", "0"], ["color", "0", "0", "0", "0"],
                           ["uuid", self.uid("j")]])

    def label(self, name, x, y, left=False):
        self.items.append(["label", Q(name), ["at", mm(x), mm(y), "180" if left else "0"],
                           effects("right bottom" if left else "left bottom"), ["uuid", self.uid("l")]])

    def nc(self, x, y):
        self.items.append(["no_connect", ["at", mm(x), mm(y)], ["uuid", self.uid("nc")]])

    def text(self, s, x, y, size=1.27, justify="left"):
        self.items.append(["text", Q(s.replace("\n", "\\n")), ["exclude_from_sim", "no"], ["at", mm(x), mm(y), "0"],
                           effects(justify, size=size), ["uuid", self.uid("t")]])

    def power(self, name, x, y, angle=0):
        self.pwr += 1
        off = (0, -3) if name != "GND" else (0, 3)
        off = rot(off[0], off[1], angle)
        self.place("power:" + name, "#PWR%02d" % self.pwr, name, x, y, angle,
                   ref_at=(0, 0), val_at=off, bom=False, just="")

    def flag(self, x, y, angle=0):
        self.pwr += 1
        self.place("power:PWR_FLAG", "#FLG%02d" % self.pwr, "PWR_FLAG", x, y, angle, bom=False, just="")

    def stub(self, ref, num, net, length=6):
        """A short wire out of a module pin ending in a net label, a GND symbol, or (net None) a
        no-connect flag on the pin itself."""
        x, y = self.pin(ref, num)
        left = x < self.placed[ref][0]
        if net is None:
            self.nc(x, y)
            return
        if net == "GND":
            length += 4                                 # keep GND symbols clear of the net labels
        end = x - length if left else x + length
        self.wire((x, y), (end, y))
        if net == "GND":
            self.power("GND", end, y)
        else:
            self.label(net, end, y, left=left)

    def flag_stub(self, ref, num, start, end):
        """A PWR_FLAG on a module pin's stub, start..end units out from the pin."""
        x, y = self.pin(ref, num)
        d = -1 if x < self.placed[ref][0] else 1
        self.wire((x + d * start, y), (x + d * end, y))
        self.flag(x + d * end, y)

    def series(self, ref, value, x, y, net_a, net_b, footprint=R0603, fields=None, lib_id="Device:R"):
        """A horizontal two-pin part between two net labels, pin 1 on the left."""
        self.place(lib_id, ref, value, x, y, 90, footprint=footprint, ref_at=(0, -3.5), val_at=(0, -2),
                   fields=fields, just="")
        p1, p2 = self.pin(ref, 1), self.pin(ref, 2)
        assert p1[0] < p2[0], (ref, p1, p2)
        self.wire((p1[0] - 4, y), p1)
        self.label(net_a, p1[0] - 4, y, left=True)
        self.wire(p2, (p2[0] + 4, y))
        self.label(net_b, p2[0] + 4, y)

    def shunt(self, ref, value, x, y_rail, footprint, fields=None, lib_id="Device:C"):
        """A vertical two-pin part hanging from a horizontal rail at y_rail down to GND."""
        self.place(lib_id, ref, value, x, y_rail + 5, footprint=footprint, fields=fields)
        self.wire((x, y_rail), self.pin(ref, 1))
        self.junction(x, y_rail)
        self.power("GND", *self.pin(ref, 2))

    # ------------------------------------------------------------ output
    def save(self, title, rev, date, comment, paper="A4"):
        name = self.project
        sheet = ["kicad_sch", ["version", "20250114"], ["generator", Q("eeschema")],
                 ["generator_version", Q("9.0")], ["uuid", self.root], ["paper", Q(paper)],
                 ["title_block", ["title", Q(title)], ["date", Q(date)], ["rev", Q(rev)], ["comment", "1", Q(comment)]],
                 ["lib_symbols"] + list(self.lib_symbols.values())] + self.items + [
            ["sheet_instances", ["path", Q("/"), ["page", Q("1")]]], ["embedded_fonts", "no"]]
        out = os.path.join(self.out_dir, name + ".kicad_sch")
        with open(out, "w") as f:
            f.write(dump(sheet) + "\n")
        # Project library: every board writes the module symbols it uses; merge by name.
        libfile = os.path.join(LIBDIR, "oft.kicad_sym")
        have = {}
        if os.path.exists(libfile):
            have = {str(s[1]): s for s in find(parse(open(libfile).read()), "symbol")}
        have.update({str(s[1]): s for s in self.custom})
        with open(libfile, "w") as f:
            f.write(dump(["kicad_symbol_lib", ["version", "20241209"], ["generator", Q("kicad_symbol_editor")],
                          ["generator_version", Q("9.0")]] + [have[k] for k in sorted(have)]) + "\n")
        for table, kind, uri in (("sym-lib-table", "sym_lib_table", "${KIPRJMOD}/../lib/oft.kicad_sym"),
                                 ("fp-lib-table", "fp_lib_table", "${KIPRJMOD}/../lib/oft.pretty")):
            with open(os.path.join(self.out_dir, table), "w") as f:
                f.write('(%s\n\t(version 7)\n\t(lib (name "oft")(type "KiCad")(uri "%s")(options "")'
                        '(descr "Open FPV Timer modules"))\n)\n' % (kind, uri))
        print("wrote", os.path.normpath(out))
