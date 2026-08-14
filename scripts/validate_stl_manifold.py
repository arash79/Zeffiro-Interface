#!/usr/bin/env python3
"""Check STL meshes for closed (watertight) manifold properties."""

from __future__ import annotations

import struct
import sys
from collections import Counter
from pathlib import Path


def read_binary_stl(path: Path) -> tuple[list[tuple[float, float, float]], list[tuple[int, int, int]]]:
    data = path.read_bytes()
    if len(data) < 84:
        raise ValueError(f"{path}: file too small")
    tri_count = struct.unpack_from("<I", data, 80)[0]
    verts: list[tuple[float, float, float]] = []
    tris: list[tuple[int, int, int]] = []
    offset = 84
    for _ in range(tri_count):
        # normal (3f) + v1 v2 v3 (9f) + attr uint16
        chunk = struct.unpack_from("<12fH", data, offset)
        v1, v2, v3 = chunk[3:6], chunk[6:9], chunk[9:12]
        i1 = len(verts)
        verts.extend([tuple(v1), tuple(v2), tuple(v3)])
        tris.append((i1, i1 + 1, i1 + 2))
        offset += 50
    return verts, tris


def weld_vertices(
    verts: list[tuple[float, float, float]], tris: list[tuple[int, int, int]], decimals: int = 4
) -> list[tuple[int, int, int]]:
    """Merge coincident vertices (binary STL stores one copy per triangle)."""
    key_to_idx: dict[tuple[float, float, float], int] = {}
    welded: list[tuple[float, float, float]] = []
    new_tris: list[tuple[int, int, int]] = []

    def key(v: tuple[float, float, float]) -> tuple[float, float, float]:
        return tuple(round(c, decimals) for c in v)

    for a, b, c in tris:
        remapped = []
        for idx in (a, b, c):
            v = verts[idx]
            k = key(v)
            if k not in key_to_idx:
                key_to_idx[k] = len(welded)
                welded.append(v)
            remapped.append(key_to_idx[k])
        new_tris.append((remapped[0], remapped[1], remapped[2]))
    return new_tris


def analyze(path: Path) -> dict:
    verts, tris = read_binary_stl(path)
    tris = weld_vertices(verts, tris)
    edge_count: Counter[tuple[int, int]] = Counter()
    for a, b, c in tris:
        for u, v in ((a, b), (b, c), (c, a)):
            edge = (u, v) if u < v else (v, u)
            edge_count[edge] += 1
    boundary = sum(1 for c in edge_count.values() if c == 1)
    nonmanifold = sum(1 for c in edge_count.values() if c > 2)
    interior = sum(1 for c in edge_count.values() if c == 2)
    return {
        "path": str(path),
        "triangles": len(tris),
        "vertices": len(verts),
        "boundary_edges": boundary,
        "nonmanifold_edges": nonmanifold,
        "interior_edges": interior,
        "watertight": boundary == 0 and nonmanifold == 0,
        "two_manifold": nonmanifold == 0,
    }


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("Usage: validate_stl_manifold.py <dir-or-stl> ...")
        return 1
    paths: list[Path] = []
    for arg in argv[1:]:
        p = Path(arg)
        if p.is_dir():
            paths.extend(sorted(p.glob("*.stl")))
        else:
            paths.append(p)
    if not paths:
        print("No STL files found.")
        return 1
    ok = True
    for p in paths:
        try:
            r = analyze(p)
        except Exception as exc:
            print(f"{p}: ERROR {exc}")
            ok = False
            continue
        status = "OK" if r["watertight"] else "OPEN"
        print(
            f"{p.name}: {status}  tris={r['triangles']}  "
            f"boundary_edges={r['boundary_edges']}  nonmanifold={r['nonmanifold_edges']}"
        )
        if not r["watertight"]:
            ok = False
    return 0 if ok else 2


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
