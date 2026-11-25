"""All figures (main and supplemental) as PNG + PDF in figures/. Fig. 1 and Fig. 2 are built by fig1.py and
fig2.py, which this script calls at the end."""
import os, runpy, pickle, warnings; warnings.filterwarnings('ignore')
import numpy as np
from config import FIGURES, ROOT
from common import *
import scipy.stats as st, matplotlib
matplotlib.use('Agg'); import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
from matplotlib.lines import Line2D
OUT = FIGURES + os.sep
R = load('fourier.pkl'); N = load('additional.pkl'); sig = load('sigma.pkl')
plt.rcParams.update({'font.family': 'DejaVu Sans', 'font.size': 8, 'axes.spines.top': False, 'axes.spines.right': False,
                     'axes.linewidth': .6, 'xtick.major.width': .6, 'ytick.major.width': .6, 'legend.frameon': False,
                     'savefig.dpi': 300, 'mathtext.default': 'it', 'axes.titleweight': 'normal'})
# colours chosen to differ in lightness so they survive greyscale printing
TEAL = '#00796b'; MAG = '#d6338a'; LMAG = '#f2a7cc'; TAN = '#c99a3c'; K = '#111111'; GREY = '#8c8c8c'; PUR = '#4a2a7a'
T = {'sensorimotor': 'Sensorimotor-confidence task', 'motoraware': 'Motor-awareness confidence task'}
def g(t, k): return np.array([R[(s, t)][k] for s in SUBJ])
SIG = {t: bh(g(t, 'conf_p')) < .01 for t in T}; RSIG = bh(g('motoraware', 'rep_p')) < .01
EX = [2, 3, 16, 19]
SM = np.array([sig[s][0] for s in SUBJ]); SP = np.array([sig[s][1] for s in SUBJ])
BIG = {  # per-figure font sizes
    'Fig03_localization': dict(lab=9.5),
    'Fig04_raw_timeseries': dict(lab=9.5, tick=8.5, leg=8.5, rect=(0, 0, 1, 0.955)),
    'Fig05_spectra': dict(lab=9, tick=8, rect=(0, 0, 1, 0.96)),
    'Fig06_SM_components': dict(leg=8),
    'Fig07_modulation_strength': dict(lab=9.5, tick=8, leg=8),
    'Fig09_mismatch': dict(lab=9.5, tick=8, leg=8),
    'Fig10_MA_components': dict(lab=9.5, tick=8, leg=8),
    'Fig11_report_weights': dict(lab=9.5, tick=8, leg=8, rect=(0, 0.14, 1, 1)),
    'Fig14_points_benchmarks': dict(lab=9.5, tick=8, leg=8, rect=(0, 0.12, 1, 1)),
    'Fig15_state_space': dict(lab=9.5, tick=8, leg=8),
    'FigS1_localization_all': dict(lab=9.5, tick=8, leg=8),
    'FigS2_SM_cycles_all': dict(tick=8, rect=(0, 0, 0.985, 0.96)),
    'FigS3_SM_mismatch_all': dict(lab=9.5, tick=8, leg=8),
    'FigS4_MA_cycles_all': dict(tick=8, rect=(0, 0, 0.985, 0.96)),
    'FigS5_MA_mismatch_all': dict(lab=9.5, tick=8, leg=8),
    'FigS6_halves': dict(lab=9.5, tick=8, leg=8),
}
def enlarge(f, lab=None, tick=None, leg=None, rect=None):
    for ax in f.axes:
        if lab:
            if not ax.xaxis.label.get_text().startswith('significant confidence'): ax.xaxis.label.set_size(lab)
            ax.yaxis.label.set_size(lab)
        if tick:
            for axis in (ax.xaxis, ax.yaxis):
                n = len([t for t in axis.get_ticklabels() if t.get_text()]) or len(axis.get_ticklocs())
                for t in axis.get_ticklabels():
                    cur = t.get_fontsize(); t.set_fontsize(tick if n <= 12 else (cur + 0.5 if cur >= 6.5 else cur))
        lg = ax.get_legend()
        if leg and lg is not None:
            for t in lg.get_texts(): t.set_fontsize(leg)
            if lg.get_title(): lg.get_title().set_fontsize(leg)
    if leg:
        for lg in f.legends:
            for t in lg.get_texts(): t.set_fontsize(leg)
            if lg.get_title(): lg.get_title().set_fontsize(leg)
    if rect is not None: f.tight_layout(rect=rect)
    else: f.tight_layout()
def save(f, name):
    if name in BIG: enlarge(f, **BIG[name])
    f.savefig(OUT + name + '.png', bbox_inches='tight'); f.savefig(OUT + name + '.pdf', bbox_inches='tight'); plt.close(f)
def panel(ax, letter, title='', x=-0.02, y=1.04, size=8):
    ax.text(x, y, letter, transform=ax.transAxes, fontweight='bold', fontsize=10, ha='right', va='bottom')
    if title: ax.text(x + 0.03, y, title, transform=ax.transAxes, fontsize=size, ha='left', va='bottom')
from matplotlib.ticker import FixedLocator, NullLocator
def logticks(ax, axis='y', ticks=(0.3, 1, 3, 10, 30)):
    a = ax.yaxis if axis == 'y' else ax.xaxis
    a.set_major_locator(FixedLocator(ticks)); a.set_minor_locator(NullLocator()); a.set_major_formatter(matplotlib.ticker.FuncFormatter(lambda v, p: ('%g' % v)))
def wrap_rep(L): return L - 20 if L > 15 else L
def fcomp(x, k):
    F = np.fft.fft(x - x.mean())[k]; return 2 * abs(F) / len(x), np.angle(F)
def snr(x, k):
    a = 2 * np.abs(np.fft.fft(x - x.mean())) / len(x); nb = list(range(k - 5, k)) + list(range(k + 1, k + 6)); return a[k] / a[nb].mean()
def cycle(x):
    M = x.reshape(12, 20); m = M.mean(0); ci = 1.96 * M.std(0, ddof=1) / np.sqrt(12); return m, ci
def label_points(ax, x, y, labels, fs=5.5, color=K, dx=0.012, dy=0.012):
    """place number labels next to points, nudging to avoid overlapping each other and the points"""
    xl = ax.get_xlim(); yl = ax.get_ylim(); logx = ax.get_xscale() == 'log'; logy = ax.get_yscale() == 'log'
    tx = lambda v: (np.log10(v) - np.log10(xl[0])) / (np.log10(xl[1]) - np.log10(xl[0])) if logx else (v - xl[0]) / (xl[1] - xl[0])
    ty = lambda v: (np.log10(v) - np.log10(yl[0])) / (np.log10(yl[1]) - np.log10(yl[0])) if logy else (v - yl[0]) / (yl[1] - yl[0])
    P = np.c_[[tx(v) for v in x], [ty(v) for v in y]]
    cands = [(dx, dy), (dx, -dy - .025), (-dx - .03, dy), (-dx - .03, -dy - .025), (dx + .02, 0), (-dx - .05, 0), (0, dy + .02), (0, -dy - .045),
             (2 * dx + .02, 2 * dy + .01), (-2 * dx - .05, 2 * dy + .01), (2 * dx + .02, -2 * dy - .04), (-2 * dx - .05, -2 * dy - .04)]
    placed = []
    for i in np.argsort(-P[:, 1]):
        best = None
        for c in cands:
            q = P[i] + c; w = 0.012 * len(str(labels[i])) + .008
            box = (q[0], q[1], q[0] + w, q[1] + .03)
            if box[0] < 0 or box[2] > 1.02 or box[1] < 0 or box[3] > 1.02: pen = 5
            else: pen = 0
            for b in placed:
                if not (box[2] < b[0] or box[0] > b[2] or box[3] < b[1] or box[1] > b[3]): pen += 1
            for j, p in enumerate(P):
                if box[0] - .006 < p[0] < box[2] + .006 and box[1] - .006 < p[1] < box[3] + .006: pen += .7
            if best is None or pen < best[0]: best = (pen, box, q)
            if pen == 0: break
        placed.append(best[1])
        ax.text(best[2][0], best[2][1], str(labels[i]), transform=ax.transAxes, fontsize=fs, color=color, ha='left', va='bottom')

# ---------- Fig 3 localization
f, axs = plt.subplots(1, 5, figsize=(7.8, 2.6), gridspec_kw={'width_ratios': [2.1, 1, 1, 1, 1]})
ax = axs[0]; ax.plot([0, 20], [0, 20], ls='--', c=GREY, lw=.6); ax.scatter(SM, SP, s=9, c=K, zorder=3)
ax.set_xlim(1.5, 8); ax.set_ylim(1, 12)
label_points(ax, SM, SP, list(range(1, 21)))
ax.set_xlabel('motor uncertainty\n$\\sigma_m$ (deg)'); ax.set_ylabel('proprioceptive uncertainty\n$\\sigma_p$ (deg)'); panel(ax, 'A', x=-0.18)
for j, p in enumerate(EX):
    s = SUBJ[p - 1]; r, rp = locgeo(s); ax = axs[j + 1]
    if s == 'EN': r = r.copy(); rp = rp.copy(); r[np.abs(r) > 30] = r.mean(); rp[np.abs(rp) > 30] = rp.mean()
    ax.scatter(r, rp, s=5, c=K, alpha=.6, lw=0); rm, rpp = 1 / sig[s][0] ** 2, 1 / sig[s][1] ** 2; k = rpp / (rpp + rm); xx = np.array([-20, 20]); ax.plot(xx, k * xx, c=MAG, lw=1.2)
    ax.plot(xx, xx, c=GREY, ls='--', lw=.5); ax.set_xlim(-20, 20); ax.set_ylim(-20, 20); ax.set_title(f'P{p}', fontsize=8)
    ax.set_xlabel('end point error\n(deg)')
    if j == 0: ax.set_ylabel('reported direction (deg)'); panel(ax, 'B', x=-0.3)
f.tight_layout(); save(f, 'Fig03_localization')

# ---------- Fig 4 raw time series (greyscale-safe: line style + lightness)
f, axs = plt.subplots(4, 1, figsize=(7, 6.4), sharex=True)
for i, (t, p) in enumerate([('sensorimotor', 2), ('sensorimotor', 19), ('motoraware', 2), ('motoraware', 19)]):
    d = task(SUBJ[p - 1], t); ax = axs[i]; x = np.arange(1, 241)
    ax.plot(x, d['clamp'], c=K, lw=1.0, label='error clamp'); ax.plot(x, d['reach'], c=TEAL, lw=1.3, ls=(0, (4, 1.5)), label='reach direction')
    if t == 'motoraware': ax.plot(x, d['report'], c=TAN, lw=1.0, ls=(0, (1, 1)), label='reported direction')
    mu = d['conf'].mean(); H = 16.0
    ax.set_ylim(-H, H); ax.set_ylabel('direction (deg)'); print('Fig4 H', t, p, H)
    ax2 = ax.twinx(); ax2.plot(x, d['conf'], c=LMAG, lw=.9, label='confidence arc width'); ax2.plot(x, d['conf'], 'o', c=MAG, ms=1.3, mew=0)
    h = H; ax2.set_ylim(mu - h, mu + h); ax2.axhline(mu, c=MAG, lw=.6, ls=':')
    ax2.set_yticks([v for v in ax2.get_yticks() if mu - h <= v <= mu + h and v >= 0]); ax2.set_ylabel('arc width (deg)', color=MAG); ax2.spines['right'].set_visible(True)
    if i in (0, 2): panel(ax, 'A' if i == 0 else 'B', T[t] + f', P{p}', x=-0.005, y=1.03, size=9.5)
    else: ax.text(0.0, 1.03, T[t] + f', P{p}', transform=ax.transAxes, fontsize=9.5, va='bottom')
    if i == 2:
        h1, l1 = ax.get_legend_handles_labels(); h2, l2 = ax2.get_legend_handles_labels()
h2 = [Line2D([], [], c=LMAG, lw=.9, marker='o', mfc=MAG, mec=MAG, ms=2.5)]
axs[-1].set_xlabel('trial'); f.legend(h1 + h2, l1 + l2, ncol=4, fontsize=8.5, loc='upper center', bbox_to_anchor=(0.5, 1.03)); save(f, 'Fig04_raw_timeseries')

# ---------- Fig 5 spectra with permutation null
rng = np.random.default_rng(3)
def spec_null(x, n=4000):
    x = x - x.mean(); S = np.array([rng.permutation(x) for _ in range(n)]); A_ = 2 * np.abs(np.fft.fft(S, axis=1)) / len(x); return np.percentile(A_, 99, axis=0)
f, axs = plt.subplots(4, 2, figsize=(7, 7.2), sharex=True)
fr = np.arange(0, 61); LEG5 = {}
for r_, (t, p) in enumerate([('sensorimotor', 2), ('sensorimotor', 19), ('motoraware', 2), ('motoraware', 19)]):
    d = task(SUBJ[p - 1], t)
    for c_, (key, k, col, lab) in enumerate([('reach', 12, TEAL, 'reach direction'), ('conf', 24, MAG, 'confidence')]):
        ax = axs[r_, c_]; x = d[key]; a = 2 * np.abs(np.fft.fft(x - x.mean())) / 240; nl = spec_null(x)
        ax.fill_between(fr[1:], 0, nl[1:61], color='#dddddd', lw=0, label='99th percentile of shuffled data')
        ax.plot(fr[1:], a[1:61], c=col, lw=1.0, label=lab)
        txt = f'{"Sensorimotor" if t == "sensorimotor" else "Motor-awareness"} task, P{p}\n'
        if key == 'reach':
            txt += f'reach SNR at 12 = {snr(x, 12):.1f}'
            if t == 'motoraware':
                xr = d['report']; ar = 2 * np.abs(np.fft.fft(xr - xr.mean())) / 240; ax.plot(fr[1:], ar[1:61], c=TAN, lw=1.0, ls=(0, (1.5, 1)), label='reported direction')
                txt += f'\nreport SNR at 12 = {snr(xr, 12):.1f}'
        else: txt += f'confidence SNR at 24 = {snr(x, 24):.1f}'
        for kk in (12, 24): ax.axvline(kk, c=GREY, lw=.5, ls=':')
        ax.set_ylabel('amplitude (deg)')
        top = max(a[1:61].max(), nl[1:61].max()) * (1 + 0.16 * (txt.count('\n') + 1) * 1.6); ax.set_ylim(0, top)
        ax.text(.98, .96, txt, transform=ax.transAxes, ha='right', va='top', fontsize=8.5)
        if r_ == 0: panel(ax, 'AB'[c_], ['Direction', 'Confidence'][c_], x=-0.01, size=9)
        for h_, l_ in zip(*ax.get_legend_handles_labels()): LEG5.setdefault(l_, h_)
for ax in axs[-1]: ax.set_xlabel('frequency (cycles per session)')
f.legend(list(LEG5.values()), list(LEG5.keys()), ncol=4, fontsize=8.5, loc='upper center', bbox_to_anchor=(0.5, 1.02)); save(f, 'Fig05_spectra')

# ---------- Fig 6 / 10 component plots (no ellipses; frequency in panel titles; keys outside data)
def components(t, name):
    f, (axA, axB) = plt.subplots(1, 2, figsize=(7.2, 3.3), gridspec_kw={'width_ratios': [1.6, 1]})
    items = [(axA, 'reach', 'reach_lag', 'reach_amp', TEAL, 'o', np.ones(20, bool), 'reach')]
    if t == 'motoraware': items.append((axA, 'report', 'rep_lag', 'rep_amp', TAN, '^', RSIG, 'reported direction'))
    items.append((axB, 'conf', 'conf_lag', 'conf_amp', MAG, 's', SIG[t], 'confidence'))
    for ax, key, lk, ak, col, mk, sgf, lab in items:
        L = g(t, lk); Am = g(t, ak)
        if key == 'report': L = np.array([wrap_rep(v) for v in L])
        ax.scatter(L[sgf], Am[sgf], s=22, c=col, marker=mk, edgecolors=K, lw=.4, label=lab + ', significant', zorder=3)
        if (~sgf).any(): ax.scatter(L[~sgf], Am[~sgf], s=22, facecolors='white', edgecolors=col, marker=mk, lw=.9, label=lab + ', not significant', zorder=3)
    for ax, xl in [(axA, (-5.5, 15.5)), (axB, (-5, 5))]:
        ax.axvline(0, c=K, lw=.6); ax.set_xlim(*xl); ax.set_ylim(0, None); ax.set_xlabel('lag relative to error clamp (trials)'); ax.set_ylabel('Fourier amplitude (deg)')
    for ax, key, lk, ak, col, mk, sgf, lab in items:
        L = g(t, lk); Am = g(t, ak)
        if key == 'report': L = np.array([wrap_rep(v) for v in L])
        label_points(ax, L, Am, list(range(1, 21)), color=col if col != TAN else '#8a6416')
    for ax in (axA, axB): ax.legend(fontsize=6, loc='upper center', bbox_to_anchor=(0.5, -0.22), ncol=2 if ax is axA else 1)
    axA.axvline(10, c=GREY, lw=.5, ls='--'); axA.text(9.85, axA.get_ylim()[1] * .97, 'anti-phase', fontsize=6, color=GREY, va='top', ha='right')
    panel(axA, 'A', 'Direction (12 cycles per session)', size=9); panel(axB, 'B', 'Confidence (24 cycles per session)', x=-0.03, size=9)
    f.tight_layout(); save(f, name)
components('sensorimotor', 'Fig06_SM_components'); components('motoraware', 'Fig10_MA_components')

# ---------- averaged cycles (Fig 8 SM examples, Fig 12 MA examples, Figs S2/S4 all participants)
def cycles(t, plist, name, ncol=2):
    nr = int(np.ceil(len(plist) / ncol)); f, axs = plt.subplots(nr, ncol, figsize=(3.4 * ncol * 0.9, 2.0 * nr), squeeze=False)
    j = np.arange(20); jj = np.linspace(0, 19, 200)
    for idx, p in enumerate(plist):
        ax = axs.flat[idx]; s = SUBJ[p - 1]; d = task(s, t)
        ax.plot(j + 1, d['clamp'][:20], c=K, lw=.8)
        series = [('reach', 12, TEAL, True)]
        if t == 'motoraware': series.append(('report', 12, TAN, RSIG[p - 1]))
        for key, k, col, show in series:
            m, ci = cycle(d[key]); ax.plot(j + 1, m, c=col, ls='--', lw=.7); ax.fill_between(j + 1, m - ci, m + ci, color=col, alpha=.15, lw=0)
            a, ph_ = fcomp(d[key], k); fit = d[key].mean() + (a * np.cos(2 * np.pi * jj / 20 + ph_) if show else 0 * jj); ax.plot(jj + 1, fit, c=col, lw=1)
        lim = 15
        if len(plist) > 4 and p == 6:
            for key_ in ['reach'] + (['report'] if t == 'motoraware' else []):
                m_, ci_ = cycle(d[key_]); lim = max(lim, float(np.ceil(np.max(np.abs(m_) + ci_))) + 1)
        ax.set_ylim(-lim, lim); ax.set_xticks([1, 6, 11, 16, 20])
        ax2 = ax.twinx(); ax2.spines['right'].set_visible(True)
        m, ci = cycle(d['conf']); ax2.plot(j + 1, m, c=MAG, ls='--', lw=.7); ax2.fill_between(j + 1, m - ci, m + ci, color=MAG, alpha=.15, lw=0)
        if SIG[t][p - 1]:
            c_ = d['conf']; best = None
            for phi in np.linspace(0, np.pi, 360, endpoint=False):
                bv = np.abs(np.sin(2 * np.pi * np.arange(240) / 20 - phi)); X = np.c_[np.ones(240), bv]; coef = np.linalg.lstsq(X, c_, rcond=None)[0]; sse = np.sum((c_ - X @ coef) ** 2)
                if best is None or sse < best[0]: best = (sse, coef, phi)
            _, coef, phi = best; fit = coef[0] + coef[1] * np.abs(np.sin(2 * np.pi * jj / 20 - phi))
        else: fit = d['conf'].mean() + 0 * jj
        ax2.plot(jj + 1, fit, c=MAG, lw=1)
        mu = d['conf'].mean(); hr = 12 * lim / 15; ax2.set_ylim(mu - hr, mu + hr); ax2.set_yticks([v for v in ax2.get_yticks() if mu - hr <= v <= mu + hr and v >= 0])
        ax.set_title(f'P{p}', fontsize=7 if len(plist) <= 4 else 8.5, loc='left')
        if len(plist) <= 4:
            if idx % ncol == 0: ax.set_ylabel('direction (deg)')
            if idx % ncol == ncol - 1: ax2.set_ylabel('arc width (deg)', color=MAG)
            if idx >= len(plist) - ncol: ax.set_xlabel('trial in clamp cycle')
    for k_ in range(len(plist), nr * ncol): axs.flat[k_].axis('off')
    if len(plist) > 4:
        hh = [Line2D([], [], c=K, lw=.8, label='error clamp'), Line2D([], [], c=TEAL, lw=1, label='reach direction')]
        if t == 'motoraware': hh.append(Line2D([], [], c=TAN, lw=1, label='reported direction'))
        hh += [Line2D([], [], c=MAG, lw=1, label='confidence (arc width)'), Line2D([], [], c=GREY, lw=.7, ls='--', label='averaged cycle (shaded: 95% CI)'), Line2D([], [], c=GREY, lw=1, label='fitted curve')]
        f.legend(handles=hh, ncol=3, fontsize=10.5, loc='upper center', bbox_to_anchor=(0.5, 1.06))
        f.supxlabel('trial in clamp cycle', fontsize=12); f.supylabel('direction (deg)', fontsize=12)
        f.text(1.0, 0.5, 'arc width (deg)', rotation=90, va='center', ha='left', fontsize=12, color=MAG)
    f.tight_layout(); save(f, name)
cycles('sensorimotor', EX, 'Fig08_SM_cycles'); cycles('motoraware', EX, 'Fig12_MA_cycles')
cycles('sensorimotor', list(range(1, 21)), 'FigS2_SM_cycles_all', ncol=4); cycles('motoraware', list(range(1, 21)), 'FigS4_MA_cycles_all', ncol=4)

# ---------- Fig 7 strength of confidence modulation (was Fig 8)
f = plt.figure(figsize=(7.0, 5.4)); gs = f.add_gridspec(2, 2, height_ratios=[1, 1.15]); axs = [f.add_subplot(gs[0, :]), f.add_subplot(gs[1, 0]), f.add_subplot(gs[1, 1])]
TK = [('sensorimotor', MAG, 'o', 'Sensorimotor task'), ('motoraware', PUR, 's', 'Motor-awareness task')]
ax = axs[0]
for off, (t, col, mk, lab) in enumerate(TK):
    v = g(t, 'conf_snr'); sg = SIG[t]; xs = np.arange(1, 21) + (off - .5) * 0.3
    ax.scatter(xs[sg], v[sg], c=col, s=16, marker=mk, edgecolors=col, lw=.6, zorder=3)
    ax.scatter(xs[~sg], v[~sg], facecolors='white', edgecolors=col, s=16, marker=mk, lw=.8, zorder=3)
ax.set_yscale('log'); ax.set_ylim(.25, 30); logticks(ax); ax.set_xticks(range(1, 21)); ax.tick_params(axis='x', labelsize=6.5); ax.set_xlim(0.3, 20.7)
ax.set_xlabel('participant'); ax.set_ylabel('confidence SNR\nat 24 cycles per session'); panel(ax, 'A', x=-0.02)
ax = axs[1]
for t, col, mk, lab in TK:
    x = g(t, 'reach_amp'); y = g(t, 'conf_snr'); sg = SIG[t]
    ax.scatter(x[sg], y[sg], c=col, s=16, marker=mk, zorder=3); ax.scatter(x[~sg], y[~sg], facecolors='white', edgecolors=col, s=16, marker=mk, lw=.8, zorder=3)
ax.set_yscale('log'); ax.set_ylim(.25, 30); logticks(ax); ax.set_xlabel('reach-adaptation amplitude (deg)'); ax.set_ylabel('confidence SNR\nat 24 cycles per session'); panel(ax, 'B', x=-0.02)
ax = axs[2]; x = g('sensorimotor', 'conf_snr'); y = g('motoraware', 'conf_snr'); a_, b_ = SIG['sensorimotor'], SIG['motoraware']
cols = np.where(a_ & b_, K, np.where(a_ | b_, GREY, 'white'))
ax.scatter(x, y, s=18, c=cols, edgecolors=K, lw=.6, zorder=3)
ax.set_xscale('log'); ax.set_yscale('log'); ax.set_xlim(.25, 30); ax.set_ylim(.25, 30); logticks(ax); logticks(ax, 'x')
label_points(ax, x, y, list(range(1, 21)))
ax.set_xlabel('SNR, sensorimotor task'); ax.set_ylabel('SNR, motor-awareness task'); panel(ax, 'C', x=-0.02)
h_task = [Line2D([], [], marker=mk, ls='', mfc=col, mec=col, ms=4.5, label=lab) for t, col, mk, lab in TK] + \
         [Line2D([], [], marker='o', ls='', mfc='white', mec=GREY, ms=4.5, label='open: not significant')]
axs[0].legend(handles=h_task, fontsize=6.5, loc='lower right', bbox_to_anchor=(1, 1.0), ncol=3)
h_c = [Line2D([], [], marker='o', ls='', mfc=c, mec=K, ms=4.5, label=l) for c, l in [(K, 'both tasks'), (GREY, 'one task'), ('white', 'neither task')]]
axs[2].legend(handles=h_c, fontsize=6.5, loc='upper left', bbox_to_anchor=(1.0, 1.0), ncol=1, title='significant in', title_fontsize=6.5)
f.tight_layout(); save(f, 'Fig07_modulation_strength')

# ---------- Fig 9 mismatch correlation + Figs S3/S5
def mism(t, p):
    d = task(SUBJ[p - 1], t); return np.abs(d['clamp'] - d['reach']), d['conf']
f, axs = plt.subplots(2, 3, figsize=(7.4, 4.6), gridspec_kw={'width_ratios': [1, 1, 1.9]})
for row, t in enumerate(T):
    for j, p in enumerate([2, 19]):
        ax = axs[row, j]; x, y = mism(t, p); r, pv = st.pearsonr(x, y); ax.scatter(x, y, s=4, c=MAG, alpha=.5, lw=0); b = np.polyfit(x, y, 1); xx = np.array([0, x.max()]); ax.plot(xx, np.polyval(b, xx), c=K, lw=.8)
        ax.set_title(f'P{p}: $r$ = {r:.2f}{"*" if pv < .05 else ""}', fontsize=7, loc='left'); ax.set_xlabel('|clamp − hand| (deg)')
        if j == 0: ax.set_ylabel('arc width (deg)')
    ax = axs[row, 2]; rr = []; pp = []
    for p in range(1, 21): x, y = mism(t, p); r, pv = st.pearsonr(x, y); rr.append(r); pp.append(pv)
    rr = np.array(rr); q = bh(pp) < .05; sg = SIG[t]
    ax.bar(np.arange(1, 21), rr, color=[MAG if s_ else '#f6d3e4' for s_ in sg], edgecolor=[K if qq else 'none' for qq in q], lw=.9)
    ax.set_xticks(range(1, 21)); ax.tick_params(axis='x', labelsize=5.5); ax.set_ylabel('$r$ (arc width vs.\n|clamp − hand|)'); ax.axhline(0, c=K, lw=.5)
    ax.set_xlabel('participant')
    panel(ax, 'BD'[row], T[t], x=-0.12, y=1.06, size=7.5)
    panel(axs[row, 0], 'AC'[row], '', x=-0.3, y=1.06)
f.tight_layout(); save(f, 'Fig09_mismatch')
for t, name in [('sensorimotor', 'FigS3_SM_mismatch_all'), ('motoraware', 'FigS5_MA_mismatch_all')]:
    f, axs = plt.subplots(4, 5, figsize=(7.2, 6), sharex=True, sharey=True)
    for p in range(1, 21):
        ax = axs.flat[p - 1]; x, y = mism(t, p); r, pv = st.pearsonr(x, y); ax.scatter(x, y, s=2.5, c=MAG, alpha=.5, lw=0); b = np.polyfit(x, y, 1); xx = np.array([0, 25]); ax.plot(xx, np.polyval(b, xx), c=K, lw=.6)
        ax.set_title(f'P{p}  $r$ = {r:.2f}{"*" if pv < .05 else ""}', fontsize=6.5, loc='left')
    f.supxlabel('|clamp − hand| (deg)', fontsize=10); f.supylabel('arc width (deg)', fontsize=10)
    for ax in axs.flat: ax._left_title.set_fontsize(8.5)
    f.tight_layout(); save(f, name)

# ---------- Fig S1 localization, all participants
f, axs = plt.subplots(4, 5, figsize=(7.2, 6), sharex=True, sharey=True)
for p in range(1, 21):
    s = SUBJ[p - 1]; r, rp = locgeo(s)
    if s == 'EN': r = r.copy(); rp = rp.copy(); r[np.abs(r) > 30] = r.mean(); rp[np.abs(rp) > 30] = rp.mean()
    ax = axs.flat[p - 1]; ax.scatter(r, rp, s=3, c=K, alpha=.6, lw=0); rm, rpp = 1 / sig[s][0] ** 2, 1 / sig[s][1] ** 2; k = rpp / (rpp + rm); xx = np.array([-20, 20]); ax.plot(xx, k * xx, c=MAG, lw=.9); ax.set_xlim(-20, 20); ax.set_ylim(-20, 20); ax.set_title(f'P{p}', fontsize=6.5, loc='left')
f.supxlabel('end point error (deg)', fontsize=10); f.supylabel('reported direction (deg)', fontsize=10)
for ax in axs.flat: ax._left_title.set_fontsize(8.5)
f.tight_layout(); save(f, 'FigS1_localization_all')

# ---------- Fig 13 sigma_p vs reach amplitude (was Fig 12)
f, axs = plt.subplots(1, 2, figsize=(6.2, 2.8), sharey=True)
for ax, t, L in zip(axs, T, 'AB'):
    x = g(t, 'reach_amp'); ax.scatter(x, SP, s=14, c=TEAL, zorder=3)
    b = np.polyfit(x, SP, 1); xx = np.array([x.min(), x.max()]); ax.plot(xx, np.polyval(b, xx), c=K, lw=.7, ls='--')
    ax.set_xlim(0, 18.5); ax.set_ylim(0, 12.5); label_points(ax, x, SP, list(range(1, 21)))
    panel(ax, L, T[t], x=-0.02); ax.set_xlabel('reach-adaptation amplitude (deg)')
axs[0].set_ylabel('proprioceptive uncertainty\n$\\sigma_p$ (deg)'); f.tight_layout(); save(f, 'Fig13_sigmaP_vs_adaptation')

# ---------- Fig 14 points
f, axs = plt.subplots(1, 3, figsize=(7.4, 2.9), gridspec_kw={'width_ratios': [1, 1, 1.1]})
labs = ['actual', 'clamp\nremoved', 'best\nfixed arc', 'error-\naware']
for ax, t, L in [(axs[0], 'sensorimotor', 'A'), (axs[1], 'motoraware', 'B')]:
    pb = N['points'][t][:, :4]
    for i in range(20): ax.plot(range(4), pb[i], c=MAG if SIG[t][i] else GREY, lw=.6, alpha=.7, ls='-' if SIG[t][i] else (0, (2, 1)))
    ax.plot(range(4), pb.mean(0), c=K, lw=1.8, marker='o', ms=4)
    ax.set_xticks(range(4)); ax.set_xticklabels(labs, fontsize=6.5); ax.set_ylabel('points per session'); panel(ax, L, T[t].replace(' confidence', '').replace('-confidence', ''), x=-0.02)
h = [Line2D([], [], c=MAG, lw=.8, label='significant confidence modulation'), Line2D([], [], c=GREY, lw=.8, ls=(0, (2, 1)), label='no significant modulation'), Line2D([], [], c=K, lw=1.8, marker='o', ms=4, label='mean')]

ax = axs[2]
for t, col, mk, lab in TK:
    pb = N['points'][t]; cost = pb[:, 1] - pb[:, 0]
    ax.scatter(g(t, 'conf_snr'), cost, c=col, marker=mk, s=14, label=lab)
ax.axhline(0, c=K, lw=.5); ax.set_xscale('log'); logticks(ax, 'x'); ax.set_xlabel('confidence SNR'); ax.set_ylabel('points gained by removing\nclamp-driven arc changes'); panel(ax, 'C', x=-0.02)
h += [Line2D([], [], marker=mk, ls='', mfc=col, mec=col, ms=4.5, label=lab + ' (C)') for t, col, mk, lab in TK]
f.tight_layout(rect=(0, 0.1, 1, 1)); f.legend(handles=h, fontsize=6, loc='lower center', ncol=5); save(f, 'Fig14_points_benchmarks')

# ---------- Fig 11 report weights (was Fig 13)
rep = N['report']; WH = rep['WH'][:, 0]; WC = rep['WC'][:, 0]; Kk = rep['K']; Lg = rep['LAG']
grp = np.array(['none' if not s_ else ('cursor' if abs(l) <= 2.5 else ('hand' if 8 <= l <= 13 else 'mixed')) for s_, l in zip(RSIG, Lg)])
GC = {'cursor': K, 'mixed': TAN, 'hand': TEAL, 'none': 'white'}; GM = {'cursor': 'o', 'mixed': 'D', 'hand': 's', 'none': 'o'}
GL = {'cursor': 'in phase with cursor', 'mixed': 'intermediate', 'hand': 'anti-phase (follows hand)', 'none': 'no 12-cycle component'}
f, axs = plt.subplots(1, 2, figsize=(6.6, 3.2))
ax = axs[0]; ax.plot([0, .6], [0, .6], c=GREY, ls='--', lw=.6)
for i in range(20): ax.scatter(Kk[i], WH[i], s=18, c=GC[grp[i]], marker=GM[grp[i]], edgecolors=K, lw=.5, zorder=3)
ax.set_xlim(0.05, .6); ax.set_ylim(-.08, .4); label_points(ax, Kk, WH, list(range(1, 21)))
ax.set_xlabel('predicted hand weight from localization,\n$r_p/(r_p+r_m)$'); ax.set_ylabel('hand weight in reports'); panel(ax, 'A', x=-0.02)
ax = axs[1]; ax.axhline(0, c=GREY, lw=.5); ax.axvline(0, c=GREY, lw=.5)
for nm in ['cursor', 'mixed', 'hand', 'none']:
    m = grp == nm; ax.scatter(WH[m], WC[m], s=18, c=GC[nm], marker=GM[nm], edgecolors=K, lw=.5, label=GL[nm], zorder=3)
ax.set_xlim(-.08, .4); ax.set_ylim(-.6, 1.05); label_points(ax, WH, WC, list(range(1, 21)))
ax.set_xlabel('hand weight'); ax.set_ylabel('cursor (clamp) weight'); panel(ax, 'B', x=-0.02)
h_, l_ = ax.get_legend_handles_labels(); f.tight_layout(rect=(0, 0.1, 1, 1)); f.legend(h_, l_, fontsize=6, loc='lower center', ncol=4, title='report lag relative to clamp', title_fontsize=6); save(f, 'Fig11_report_weights')

# ---------- Fig 15 state-space
SS = N['ss']; FIT = N['ssfit']
f = plt.figure(figsize=(7.4, 4.8)); gs = f.add_gridspec(2, 3, height_ratios=[1, 1.15])
ax = f.add_subplot(gs[0, :]); y, yh, c = FIT[('LL', 'sensorimotor')]; x = np.arange(1, 241)
ax.plot(x, c, c=K, lw=.7, label='error clamp'); ax.plot(x, y, c=TEAL, lw=.6, alpha=.55, label='reach (P2, sensorimotor task)'); ax.plot(x, yh, c=TEAL, lw=1.6, label='state-space model fit')
ax.set_xlabel('trial'); ax.set_ylabel('direction (deg)'); ax.legend(ncol=3, fontsize=6.5, loc='upper right', bbox_to_anchor=(1, 1.2)); panel(ax, 'A', x=-0.01)
for j, (t, L) in enumerate([('sensorimotor', 'B'), ('motoraware', 'C')]):
    ax = f.add_subplot(gs[1, j]); r = SS[t]
    for k_, (nm, col) in enumerate([('retention A', K), ('learning rate B', TEAL)]):
        v = r[:, k_]; xs = np.array([0, 1]) + k_ * 2.6
        for m, xx in [(SIG[t], xs[0]), (~SIG[t], xs[1])]:
            ax.scatter(xx + np.random.default_rng(1).uniform(-.15, .15, m.sum()), v[m], s=10, facecolors=col if xx == xs[0] else 'white', edgecolors=col, lw=.7)
            ax.plot([xx - .25, xx + .25], [v[m].mean()] * 2, c=col, lw=1.5)
    ax.set_xticks([0, 1, 2.6, 3.6]); ax.set_xticklabels(['yes', 'no', 'yes', 'no'], fontsize=6.5)
    for xx_, nm_ in [(0.5, 'retention A'), (3.1, 'learning rate B')]: ax.text(xx_, -0.15, nm_, transform=ax.get_xaxis_transform(), ha='center', va='top', fontsize=6.5, fontweight='bold')
    ax.set_xlabel('significant confidence modulation?', labelpad=20, fontsize=7)
    ax.set_ylim(-.05, 1.05); ax.set_ylabel('parameter value'); panel(ax, L, T[t].replace(' confidence', '').replace('-confidence', ''), x=-0.02, size=7.5)
ax = f.add_subplot(gs[1, 2])
for k_, (nm, col, mk) in enumerate([('retention A', K, 'o'), ('learning rate B', TEAL, 's')]):
    a, b = SS['sensorimotor'][:, k_], SS['motoraware'][:, k_]; ax.scatter(a, b, s=12, c=col, marker=mk, label=nm)
ax.plot([0, 1], [0, 1], c=GREY, ls='--', lw=.6); ax.set_xlabel('sensorimotor task'); ax.set_ylabel('motor-awareness task'); ax.legend(fontsize=6, loc='lower left', bbox_to_anchor=(0.62, 0.0), ncol=1, handletextpad=0.2, borderaxespad=0.2); panel(ax, 'D', x=-0.02)
f.tight_layout(); save(f, 'Fig15_state_space')

# ---------- Fig S6 halves
f, axs = plt.subplots(1, 4, figsize=(7.4, 2.3))
for j, (t, key, ttl) in enumerate([('sensorimotor', 0, 'Sensorimotor task:\nreach'), ('sensorimotor', 1, 'Sensorimotor task:\nconfidence'), ('motoraware', 0, 'Motor-awareness task:\nreach'), ('motoraware', 1, 'Motor-awareness task:\nconfidence')]):
    ax = axs[j]; v = N['halves_' + t][key]
    for i in range(20): ax.plot([0, 1], v[i], c=MAG if (key == 1 and SIG[t][i]) else GREY, lw=.6, alpha=.7)
    ax.plot([0, 1], v.mean(0), c=K, lw=1.6, marker='o', ms=3); p = st.ttest_rel(v[:, 0], v[:, 1]).pvalue
    ax.set_xticks([0, 1]); ax.set_xticklabels(['1st half', '2nd half']); ax.set_title(f'{ttl}\n$p$ = {p:.3f}', fontsize=8.5, loc='left')
    if j == 0: ax.set_ylabel('Fourier amplitude (deg)')
f.tight_layout(); save(f, 'FigS6_halves')
print('done')

# Fig. 1 (native-resolution composite) and Fig. 2 (prediction schematic)
runpy.run_path(os.path.join(ROOT, 'fig1.py')); runpy.run_path(os.path.join(ROOT, 'fig2.py'))
