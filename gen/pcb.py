"""Board writer shared by the board generators (pcbnew scripting, KiCad 9).

Board coordinates are millimetres from the top-left corner of the board. Placement and routing
are written out by hand in each board's gen_pcb.py; this only wraps the pcbnew calls.
"""
import math
import os

import pcbnew
from pcbnew import VECTOR2I, FromMM

from sexpr import parse, find, first

FPDIR = "/usr/share/kicad/footprints"
LIBDIR = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
F, B = pcbnew.F_Cu, pcbnew.B_Cu
SILK, BSILK, FAB, DOC, EDGE = pcbnew.F_SilkS, pcbnew.B_SilkS, pcbnew.F_Fab, pcbnew.Dwgs_User, pcbnew.Edge_Cuts
SIG, PWR = 0.25, 0.6          # track widths
VIA_D, VIA_DRILL = 0.6, 0.3


class Board:
    def __init__(self, out, netlist, title, rev, date, origin=(60.0, 60.0)):
        self.out = out
        self.ox, self.oy = origin
        self.board = pcbnew.NewBoard(out)
        tb = self.board.GetTitleBlock()
        tb.SetTitle(title)
        tb.SetRevision(rev)
        tb.SetDate(date)
        self.net_sexpr = parse(open(netlist).read())
        self.nets, self.pad_net, self.fps = {}, {}, {}
        for n in find(first(self.net_sexpr, "nets"), "net"):
            name = str(first(n, "name")[1])
            item = pcbnew.NETINFO_ITEM(self.board, name)
            self.board.Add(item)
            self.nets[name.lstrip("/")] = item
            for node in find(n, "node"):
                self.pad_net[(str(first(node, "ref")[1]), str(first(node, "pin")[1]))] = item

    def pt(self, x, y):
        return VECTOR2I(FromMM(self.ox + x), FromMM(self.oy + y))

    # ------------------------------------------------------------ footprints
    def place_all(self, place, show_value=lambda ref: ref[0] in "RCD"):
        """place: {ref: (x, y, rotation)}. Rotation is counter-clockwise, KiCad convention."""
        for comp in find(first(self.net_sexpr, "components"), "comp"):
            ref = str(first(comp, "ref")[1])
            lib, fpname = str(first(comp, "footprint")[1]).split(":")
            path = os.path.join(LIBDIR, "oft.pretty") if lib == "oft" else "%s/%s.pretty" % (FPDIR, lib)
            fp = pcbnew.FootprintLoad(path, fpname)
            fp.SetFPID(pcbnew.LIB_ID(lib, fpname))
            fp.SetReference(ref)
            fp.SetValue(str(first(comp, "value")[1]))
            fp.SetPath(pcbnew.KIID_PATH("/" + str(first(comp, "tstamps")[1])))
            x, y, angle = place[ref]
            fp.SetPosition(self.pt(x, y))
            fp.SetOrientationDegrees(angle)
            for pad in fp.Pads():
                net = self.pad_net.get((ref, pad.GetNumber()))
                if net:
                    pad.SetNet(net)
            fp.Reference().SetVisible(False)            # designators live on F.Fab; silk is hand-placed
            val = fp.Value()
            val.SetTextSize(VECTOR2I(FromMM(0.5), FromMM(0.5)))
            val.SetTextThickness(FromMM(0.08))
            val.SetVisible(show_value(ref))
            self.board.Add(fp)
            self.fps[ref] = fp

    def P(self, ref, num):
        for pad in self.fps[ref].Pads():
            if pad.GetNumber() == str(num):
                p = pad.GetPosition()
                return (round(pcbnew.ToMM(p.x) - self.ox, 4), round(pcbnew.ToMM(p.y) - self.oy, 4))
        raise KeyError((ref, num))

    def solid(self, ref, num):
        """Connect one pad to its pour without thermal relief."""
        for pad in self.fps[ref].Pads():
            if pad.GetNumber() == str(num):
                pad.SetLocalZoneConnection(pcbnew.ZONE_CONNECTION_FULL)

    def net_of(self, ref, num):
        return self.pad_net[(ref, str(num))].GetNetname().lstrip("/")

    # ------------------------------------------------------------ copper
    def track(self, net, layer, width, *pts):
        for a, b in zip(pts, pts[1:]):
            if a == b:
                continue
            t = pcbnew.PCB_TRACK(self.board)
            t.SetStart(self.pt(*a))
            t.SetEnd(self.pt(*b))
            t.SetWidth(FromMM(width))
            t.SetLayer(layer)
            t.SetNet(self.nets[net])
            self.board.Add(t)

    def via(self, net, x, y):
        v = pcbnew.PCB_VIA(self.board)
        v.SetPosition(self.pt(x, y))
        v.SetDrill(FromMM(VIA_DRILL))
        v.SetWidth(F, FromMM(VIA_D))
        v.SetLayerPair(F, B)
        v.SetNet(self.nets[net])
        self.board.Add(v)

    def _zone(self, layers, pts):
        z = pcbnew.ZONE(self.board)
        ls = pcbnew.LSET()
        for l in layers:
            ls.AddLayer(l)
        z.SetLayerSet(ls)
        o = z.Outline()
        o.NewOutline()
        for x, y in pts:
            o.Append(FromMM(self.ox + x), FromMM(self.oy + y))
        self.board.Add(z)
        return z

    def pour(self, layer, x0, y0, x1, y1, net, name):
        z = self._zone([layer], ((x0, y0), (x1, y0), (x1, y1), (x0, y1)))
        z.SetNet(self.nets[net])
        z.SetZoneName(name)
        z.SetLocalClearance(FromMM(0.3))
        z.SetMinThickness(FromMM(0.25))
        z.SetPadConnection(pcbnew.ZONE_CONNECTION_THERMAL)
        z.SetThermalReliefGap(FromMM(0.3))
        z.SetThermalReliefSpokeWidth(FromMM(0.4))
        z.SetIslandRemovalMode(pcbnew.ISLAND_REMOVAL_MODE_ALWAYS)
        return z

    def keepout(self, layers, pts, name, tracks=True):
        """A rule area with no copper pour, vias or (by default) tracks. Pads are allowed."""
        z = self._zone(layers, pts)
        z.SetIsRuleArea(True)
        z.SetZoneName(name)
        z.SetDoNotAllowCopperPour(True)
        z.SetDoNotAllowTracks(tracks)
        z.SetDoNotAllowVias(True)
        z.SetDoNotAllowPads(False)
        z.SetDoNotAllowFootprints(False)
        return z

    def keepout_rect(self, layers, x0, y0, x1, y1, name, tracks=True):
        return self.keepout(layers, ((x0, y0), (x1, y0), (x1, y1), (x0, y1)), name, tracks)

    def keepout_circle(self, layers, x, y, r, name):
        return self.keepout(layers, [(x + r * math.cos(2 * math.pi * i / 32), y + r * math.sin(2 * math.pi * i / 32))
                                     for i in range(32)], name)

    # ------------------------------------------------------------ graphics
    def _shape(self, layer, width):
        s = pcbnew.PCB_SHAPE(self.board)
        s.SetLayer(layer)
        s.SetWidth(FromMM(width))
        self.board.Add(s)
        return s

    def line(self, layer, a, b, width=0.1):
        s = self._shape(layer, width)
        s.SetShape(pcbnew.SHAPE_T_SEGMENT)
        s.SetStart(self.pt(*a))
        s.SetEnd(self.pt(*b))

    def rect(self, layer, x0, y0, x1, y1, width=0.1):
        for a, b in (((x0, y0), (x1, y0)), ((x1, y0), (x1, y1)), ((x1, y1), (x0, y1)), ((x0, y1), (x0, y0))):
            self.line(layer, a, b, width)

    def arc(self, layer, start, mid, end, width=0.1):
        s = self._shape(layer, width)
        s.SetShape(pcbnew.SHAPE_T_ARC)
        s.SetArcGeometry(self.pt(*start), self.pt(*mid), self.pt(*end))

    def outline(self, w, h, r):
        k = r * (1 - 0.7071068)
        self.line(EDGE, (r, 0), (w - r, 0)); self.arc(EDGE, (w - r, 0), (w - k, k), (w, r))
        self.line(EDGE, (w, r), (w, h - r)); self.arc(EDGE, (w, h - r), (w - k, h - k), (w - r, h))
        self.line(EDGE, (w - r, h), (r, h)); self.arc(EDGE, (r, h), (k, h - k), (0, h - r))
        self.line(EDGE, (0, h - r), (0, r)); self.arc(EDGE, (0, r), (k, k), (r, 0))

    def text(self, s, x, y, layer=SILK, size=0.8, angle=0, thick=None, just=None):
        t = pcbnew.PCB_TEXT(self.board)
        t.SetText(s)
        t.SetPosition(self.pt(x, y))
        t.SetLayer(layer)
        t.SetTextSize(VECTOR2I(FromMM(size), FromMM(size)))
        t.SetTextThickness(FromMM(thick or size * 0.15))
        t.SetTextAngleDegrees(angle)
        if layer in (pcbnew.B_SilkS, pcbnew.B_Fab):
            t.SetMirrored(True)
        if just is not None:
            t.SetHorizJustify(just)
        self.board.Add(t)

    def save(self):
        pcbnew.ZONE_FILLER(self.board).Fill(self.board.Zones())
        pcbnew.SaveBoard(self.out, self.board)
        print("wrote", self.out)
