"""Fig. 1 built at native resolution: the trial-sequence panels are pasted 1:1 from the
authors' source images (no resampling) and panel A is rendered directly at the final pixel width."""
import os, io
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
from PIL import Image, ImageDraw, ImageFont, ImageChops

from config import FIGURES as OUT, ASSETS
SRC = os.path.join(ASSETS, 'fig1') + os.sep
W = 2048                      # final width in pixels (Google Docs caps images at 2048 px)
DPI = W / 7.0                 # figure is 7 in wide in print -> ~293 ppi
FB = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 44)
FT = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 37)

# ---- panel A rendered straight to the final pixel width (no later resizing)
plt.rcParams.update({'font.family': 'DejaVu Sans'})
f = plt.figure(figsize=(7, 1.6), dpi=DPI)
ax = f.add_axes([0, 0, 1, 1]); ax.axis('off')
blocks = [('Practice\n20 trials\nveridical cursor', '#e8e8e8'), ('Localization\n40 trials\nno cursor, no clamp', '#d6e9e9'), ('', '#f3dbe7')]
for row in range(2):
    x = 0.17; y = 0.55 - row * 0.5
    ax.text(0.01, y + 0.15, f'Session {row + 1}', fontsize=8, fontweight='bold', va='center')
    for i, (b, c) in enumerate(blocks):
        wdt = [0.14, 0.17, 0.495][i]
        ax.add_patch(FancyBboxPatch((x, y), wdt, 0.3, boxstyle='round,pad=0.005', fc=c, ec='#666', lw=.6))
        tt = b if i < 2 else ['One confidence task (sensorimotor or motor awareness)', 'The other confidence task'][row] + '\n240 trials (12 clamp cycles)\nerror clamp + confidence report'
        ax.text(x + wdt / 2, y + 0.15, tt, ha='center', va='center', fontsize=6.8)
        x += wdt + 0.01
ax.text(0.17, -0.12, 'Task order counterbalanced: 10 participants did each task first.', fontsize=8.5, color='#333')
ax.set_xlim(0, 1.0); ax.set_ylim(-0.2, 0.9)
buf = io.BytesIO(); f.savefig(buf, dpi=DPI, format='png'); plt.close(f)
A = Image.open(buf).convert('RGB')
assert abs(A.width - W) <= 1, A.size
if A.width != W: A = A.crop((0, 0, W, A.height))

# ---- source panels, cropped to their content and pasted 1:1
def load(name):
    im = Image.open(SRC + name)
    rgb = Image.new('RGB', im.size, 'white')
    rgb.paste(im, mask=im.split()[3] if im.mode == 'RGBA' else None)
    bb = ImageChops.difference(rgb, Image.new('RGB', im.size, 'white')).getbbox()
    return rgb.crop(bb), bb[0]
rows = [('A', 'Session structure', A, 0),
        ('B', 'Proprioceptive localization task', *load('localization_trial.png')),
        ('C', 'Sensorimotor-confidence task', *load('sensorimotor_trial.png')),
        ('D', 'Motor-awareness confidence task', *load('motor_awareness_trial.png'))]
TITLE_H, GAP = 70, 46
H = sum(TITLE_H + r[2].height + GAP for r in rows)
canvas = Image.new('RGB', (W, H), 'white'); d = ImageDraw.Draw(canvas); y = 0
for L, ttl, im, x0 in rows:
    d.text((12, y + 8), L, font=FB, fill='black'); d.text((66, y + 14), ttl, font=FT, fill='#333')
    y += TITLE_H
    x = 0 if L == 'A' else 12
    assert x + im.width <= W, (L, x, im.width)
    canvas.paste(im, (x, y)); y += im.height + GAP
canvas = canvas.crop((0, 0, W, y - GAP + 10))
canvas.save(os.path.join(OUT, 'Fig01_task.png'), dpi=(round(DPI), round(DPI)), optimize=True)
print('Fig01_task.png', canvas.size)
