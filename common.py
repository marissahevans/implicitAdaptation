"""Shared definitions: participant order, data access, Fourier helpers, FDR, and the reconstruction of
each task's 240 experimental trials from the raw per-session files."""
import os, pickle, warnings
import numpy as np
from config import res
warnings.filterwarnings('ignore')

# Participant order used throughout the paper (P1 ... P20 = these initials)
SUBJ = ['OY', 'LL', 'CK', 'LN', 'EN', 'MH', 'HL', 'DT', 'TC', 'SX', 'MG', 'HP', 'AS', 'NK', 'JH', 'SH', 'ML', 'NM', 'ET', 'HH']
TASKS = ['sensorimotor', 'motoraware']
N = 240

_A = None
def data():
    """All loaded .mat contents (built by 01_load_data.py)."""
    global _A
    if _A is None: _A = pickle.load(open(res('all.pkl'), 'rb'))
    return _A

# ---------------------------------------------------------------- Fourier helpers
def amp(x, k):
    """Fourier amplitude (deg) at k cycles per session."""
    return 2 * np.abs(np.fft.fft(x - np.mean(x))[k]) / len(x)
def ph(x, k): return np.angle(np.fft.fft(x - np.mean(x))[k])
def lag12(x, clamp):
    """Trials by which x lags the clamp at 12 cycles/session, in [0, 20)."""
    return ((ph(clamp, 12) - ph(x, 12)) / (2 * np.pi) * 20) % 20
def lag24(x, clamp):
    """Trials by which x lags |clamp| at 24 cycles/session, wrapped to (-5, 5]."""
    L = ((ph(np.abs(clamp), 24) - ph(x, 24)) / (2 * np.pi) * 10) % 10
    return L - 10 if L > 5 else L
def snr(x, k):
    """Amplitude at k divided by the mean amplitude of the five neighbouring frequencies on each side."""
    a = 2 * np.abs(np.fft.fft(x - x.mean())) / len(x); nb = np.r_[a[k - 5:k], a[k + 1:k + 6]]; return a[k] / nb.mean()
def bh(p):
    """Benjamini-Hochberg adjusted p-values."""
    p = np.asarray(p, float); n = len(p); o = np.argsort(p); q = p[o] * n / np.arange(1, n + 1)
    q = np.minimum.accumulate(q[::-1])[::-1]; out = np.empty(n); out[o] = np.minimum(q, 1); return out

# ---------------------------------------------------------------- which raw files make up each task
# Most participants have one 300-trial file per session (trials 61-300 = the 240 experimental trials).
# Sessions that were split across files, or files with unusual names, are listed explicitly.
SRC = {
 'sensorimotor': {'CK': [('S1_2025-03-06_16-25', 61, 300)], 'OY': [('S2_2025-03-04_16-00', 61, 300)]},
 'motoraware': {'OY': [('S1_2025-03-04_14-26', 61, 120), ('S1_2025-03-04_15-17', 121, 300)],
                'MG': [('S2_2025-03-27_15-00', 61, 240), ('S2_2025-03-27_16-58', 241, 300)],
                'SX': [('S1_2025-03-26_16-18', 61, 120), ('S1_2025-03-26_16-45', 121, 300)],
                'CK': [('S2_2025-03-06_17-26', 61, 300)], 'HL': [('S2_2025-05-09_12-26', 61, 300)]}}
SM_FIRST = ['CK', 'MG', 'LL', 'LN', 'MH', 'ET', 'HH', 'HL', 'JH', 'AS']   # did the sensorimotor task in session 1
def sources(s, task, raws):
    if s in SRC[task]: return SRC[task][s]
    full = [x for x in raws if len(x['e'].endPtAngle) == 300]
    sess = 1 if ((s in SM_FIRST) == (task == 'sensorimotor')) else 2
    f = [x for x in full if x['sess'] == sess]
    assert len(f) == 1, (s, task, [x['file'] for x in f])
    return [(f[0]['file'].split('_exp_')[1].replace('_errresults.mat', ''), 61, 300)]
def get(raws, tag): return [x for x in raws if tag in x['file']][0]

# ---------------------------------------------------------------- reported direction from the screen
def geo_report(e, a, b):
    """Reported direction from the on-screen position of the report dot (reportArc), in the same frame as
    endPtAngle - 90 (positive = leftward). Used instead of the processed 'report' variable, whose sign was
    inverted for most files."""
    arc = np.asarray(e.reportArc, float); stp = np.asarray(e.startPos, float)
    if arc.ndim == 2 and len(arc) >= b:
        ang = np.degrees(np.arctan2(-(arc[a:b, 1] - stp[1]), arc[a:b, 0] - stp[0])) - 90
        ang[np.abs(ang) > 60] = np.nan      # rows that were never set
        return ang
    return None
def task_geo(s, t):
    """Raw trial-by-trial variables for one participant and task (240 trials)."""
    A = data(); raws = A[s]['raw']; out = {k: [] for k in ['report_raw', 'reach_raw', 'clamp', 'conf', 'points', 'arcstart', 'conftime']}
    for tag, a, b in sources(s, t, raws):
        e = get(raws, tag)['e']
        out['report_raw'].append(geo_report(e, a - 1, b) if t == 'motoraware' else np.full(b - a + 1, np.nan))
        out['reach_raw'].append(np.asarray(e.endPtAngle, float)[a - 1:b] - 90)
        out['clamp'].append(np.asarray(e.errorClamp, float)[a - 1:b] - 90)
        out['conf'].append(np.asarray(e.confAngle, float)[a - 1:b])
        out['points'].append(np.asarray(e.pointsEarned, float)[a - 1:b])
        out['arcstart'].append(np.asarray(e.arcStart, float)[a - 1:b])
        out['conftime'].append(np.asarray(e.confTime, float)[a - 1:b])
    return {k: np.concatenate(v) for k, v in out.items()}
def task(s, t):
    """Variables used in the Fourier analyses: clamp, reach (mean-centred), confidence (arc width), points,
    and in the motor-awareness task the sign-corrected report (mean-centred)."""
    P = data()[s][t]
    d = dict(clamp=P['errClamp'].astype(float), reach=P['endPt'].astype(float), conf=P['confRep'].astype(float),
             points=P['pointsEarned'].astype(float))
    if t == 'motoraware':
        g = task_geo(s, t); r = g['report_raw'].copy(); r[~np.isfinite(r)] = np.nanmean(r)
        d['report'] = r - r.mean(); d['report_raw'] = g['report_raw']
    return d

# ---------------------------------------------------------------- proprioceptive localization (trials 21-60 of each session)
# Files used for each participant, as listed in the lab script clampFitSigmaP.m
LOC_FILES = {'OY': ['S1_2025-03-04_14-26', 'S3_2025-03-07_16-55'], 'CK': ['S2_2025-03-06_17-01', 'S1_2025-03-06_15-50'], 'MG': ['S1_2025-03-24_14-48', 'S2_2025-03-27_15-00'],
 'SX': ['S1_2025-03-26_15-50', 'S2_2025-04-10_15-00'], 'ML': ['S1_2025-03-25_14-59', 'S2_2025-03-25_16-34'], 'LL': ['S1_2025-03-27_12-50', 'S2_2025-03-28_14-45'],
 'LN': ['S1_2025-04-10_16-00', 'S2_2025-04-14_15-46'], 'EN': ['S1_2025-04-15_15-57', 'S2_2025-04-15_17-07'], 'NK': ['S1_2025-04-17_15-29', 'S2_2025-04-17_16-20'],
 'SH': ['S1_2025-04-25_15-16', 'S2_2025-04-25_16-30'], 'HP': ['S1_2025-04-29_09-01', 'S2_2025-04-29_09-45'], 'DT': ['S1_2025-04-28_13-01', 'S2_2025-04-29_13-59'],
 'MH': ['S1_2025-04-24_16-06', 'S2_2025-04-30_15-55'], 'TC': ['S1_2025-05-02_15-05', 'S2_2025-05-02_16-30'], 'ET': ['S1_2025-04-30_13-59', 'S2_2025-05-07_13-59'],
 'HH': ['S1_2025-05-06_16-00', 'S2_2025-05-07_16-00'], 'HL': ['S1_2025-04-29_13-02', 'S2_2025-05-09_12-14'], 'JH': ['S1_2025-05-07_15-01', 'S2_2025-05-12_13-58'],
 'AS': ['S1_2025-05-09_15-12', 'S2_2025-05-12_15-03'], 'NM': ['S1_2025-05-13_16-14', 'S2_2025-05-13_17-19']}
def locgeo(s):
    """End point error and (sign-corrected) reported direction for the 80 localization trials."""
    A = data(); r = []; p = []
    for t in LOC_FILES[s]:
        e = get(A[s]['raw'], t)['e']; g = geo_report(e, 20, 60)
        if g is None or np.all(np.isnan(g)): g = np.full(40, np.nan)
        r += list(np.asarray(e.endPtAngle, float)[20:60] - 90); p += list(g)
    r = np.array(r); p = np.array(p); ok = np.isfinite(p)
    r, p = r[ok], p[ok]
    if s == 'EN':   # two trials with |x| > 30 deg replaced by the mean, as in the lab script
        r = r.copy(); p = p.copy(); r[np.abs(r) > 30] = r.mean(); p[np.abs(p) > 30] = p.mean()
    return r, p
SIG_GRID = np.arange(1, 40.01, .1)
def fit_sigma(reach, report, correct=False, stat='mode'):
    """Grid fit of motor (sigma_m) and proprioceptive (sigma_p) uncertainty, as in clampFitSigmaP.m.
    correct=True adds the 1/2 factors of the Gaussian likelihood that the lab script omits (not used in the paper)."""
    m = SIG_GRID; M, P = np.meshgrid(m, m, indexing='ij'); rm = 1 / M ** 2; rp = 1 / P ** 2; k = rp / (rp + rm); n = len(reach); sd = k * P
    c = 0.5 if correct else 1.0
    LLe = -c * n * np.log(2 * np.pi) - 2 * c * n * np.log(M) - np.sum(reach ** 2) / (2 * M ** 2)
    q = np.sum(report ** 2) - 2 * k * np.sum(report * reach) + k ** 2 * np.sum(reach ** 2)
    LLi = -c * n * np.log(2 * np.pi) - 2 * c * n * np.log(sd) - q / (2 * sd ** 2)
    LL = LLe + LLi; Pn = np.exp(LL - LL.max()); mm = Pn.sum(1); pm = Pn.sum(0)
    if stat == 'mode': return m[np.argmax(mm)], m[np.argmax(pm)]
    if stat == 'mean': return np.sum(m * mm) / mm.sum(), np.sum(m * pm) / pm.sum()
    i = np.unravel_index(np.argmax(LL), LL.shape); return m[i[0]], m[i[1]]

def ols(y, X):
    """OLS with intercept: coefficients, two-sided p, standard errors, AIC."""
    import scipy.stats as st
    X = np.c_[np.ones(len(y)), X]; b = np.linalg.lstsq(X, y, rcond=None)[0]; r = y - X @ b; n, k = X.shape
    s2 = r @ r / (n - k); se = np.sqrt(np.diag(s2 * np.linalg.inv(X.T @ X))); p = 2 * st.t.sf(abs(b / se), n - k)
    aic = n * np.log(r @ r / n) + 2 * (k + 1)
    return b, p, se, aic
def load(name): return pickle.load(open(res(name), 'rb'))
def save(obj, name): pickle.dump(obj, open(res(name), 'wb'))
