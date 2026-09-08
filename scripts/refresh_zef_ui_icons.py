#!/usr/bin/env python3
"""Regenerate PNG icons from SVG masters for zef_ui_icons.

Usage:
    python3 scripts/refresh_zef_ui_icons.py [size]

The SVG masters live in assets/fig/ui/Zeffiro_Modern_Icons/svg_masters/.
Square PNGs with transparency are written to assets/fig/ui/<stem>.png,
which is the location expected by src/gui/chrome/zef_ui_icons.m.

Requires:
    - Python 3 with svglib and reportlab (pip install svglib)
    - macOS sips (Scriptable Image Processing System)
"""
import os
import subprocess
import sys
import tempfile

try:
    from svglib.svglib import svg2rlg
    from reportlab.graphics import renderPDF
    from reportlab.pdfgen import canvas
except ImportError as exc:
    sys.exit(
        "Missing Python dependency: {}\n"
        "Install with: pip install --user svglib".format(exc)
    )


ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SVG_DIR = os.path.join(ROOT, 'assets', 'fig', 'ui', 'Zeffiro_Modern_Icons', 'svg_masters')
OUT_DIR = os.path.join(ROOT, 'assets', 'fig', 'ui')
DEFAULT_SIZE = 128


def svg_to_pdf(svg_path, pdf_path):
    drawing = svg2rlg(svg_path)
    if drawing is None:
        raise RuntimeError('svg2rlg failed for {}'.format(svg_path))
    c = canvas.Canvas(pdf_path, pagesize=(drawing.width, drawing.height))
    renderPDF.draw(drawing, c, 0, 0)
    c.save()


def pdf_to_png(pdf_path, png_path, size):
    cmd = [
        'sips', '-z', str(size), str(size),
        '-s', 'format', 'png',
        pdf_path, '--out', png_path
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError('sips failed: {}\n{}'.format(result.returncode, result.stderr))


def main():
    size = int(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_SIZE
    if not os.path.isdir(SVG_DIR):
        sys.exit('SVG directory not found: {}'.format(SVG_DIR))
    os.makedirs(OUT_DIR, exist_ok=True)

    svg_files = sorted([f for f in os.listdir(SVG_DIR) if f.lower().endswith('.svg')])
    if not svg_files:
        sys.exit('No SVG files found in {}'.format(SVG_DIR))

    with tempfile.TemporaryDirectory() as tmpdir:
        for svg_name in svg_files:
            stem = os.path.splitext(svg_name)[0]
            svg_path = os.path.join(SVG_DIR, svg_name)
            png_path = os.path.join(OUT_DIR, '{}.png'.format(stem))
            pdf_path = os.path.join(tmpdir, '{}.pdf'.format(stem))
            try:
                svg_to_pdf(svg_path, pdf_path)
                pdf_to_png(pdf_path, png_path, size)
                print('{} -> {} ({}x{})'.format(svg_name, png_path, size, size))
            except Exception as exc:
                print('ERROR converting {}: {}'.format(svg_name, exc))
                raise


if __name__ == '__main__':
    main()
