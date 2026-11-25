"""Descriptive numbers quoted in the Methods and Results that are not printed by the other scripts:
session spacing and duration, reach kinematics, points and hit rates, example spectral SNRs,
rectified-sinusoid vs. Fourier classification, report amplitudes and lags, and arc width vs. the best
fixed arc. Run after 01-08. Prints to the console only."""
import datetime as dt
import scipy.stats as st
from common import *

A = data()
R = load('fourier.pkl'); KIN = load('kinematics.pkl'); ADD = load('additional.pkl')
def g(t, k): return np.array([R[(s, t)][k] for s in SUBJ])
SIG = {t: bh(g(t, 'conf_p')) < .01 for t in TASKS}
def tdate(tag): return dt.datetime.strptime(tag[3:], '%Y-%m-%d_%H-%M')

print('================ SESSIONS (Methods: Participants / Procedure)')
gaps, dur = [], []
for s in SUBJ:
    raws = A[s]['raw']; day = {}
    for t in TASKS:
        src = sources(s, t, raws); minutes = 0
        for tag, a, b in src:
            e = get(raws, tag)['e']
            st0 = np.asarray(e.startTimes, float); me = np.asarray(e.moveEnd, float)
            minutes += (me[me > 0].max() - st0[st0 > 0].min()) / 60   # first trial start to last reach end
        dur.append(minutes); day[t] = tdate(src[0][0]).date()
    gaps.append(abs((day['sensorimotor'] - day['motoraware']).days))
gaps = np.array(gaps); sep = gaps[gaps > 0]
print('same day: %d, separate days: %d (%d-%d days apart, median %.0f)' % ((gaps == 0).sum(), len(sep), sep.min(), sep.max(), np.median(sep)))
print('session duration: mean %.1f min (median %.1f, range %.0f-%.0f)' % (np.mean(dur), np.median(dur), min(dur), max(dur)))

print('================ REACH KINEMATICS (both confidence tasks, 240 trials each)')
# columns: stop_mm, MT, peak_vel, dir50, dir_target, cross_angle, endPtAngle, sample_dt
per = {k: [] for k in ['stop', 'mt', 'pv', 'ddir']}; short = []; rr = []; sl = []
for s in SUBJ:
    K = np.vstack([KIN[(s, t)] for t in TASKS])
    per['stop'].append(np.nanmean(K[:, 0])); per['mt'].append(np.nanmean(K[:, 1]) * 1000)
    per['pv'].append(np.nanmean(K[:, 2])); per['ddir'].append(np.nanmean(np.abs(K[:, 4] - K[:, 3])))
    short.append(K[np.isfinite(K[:, 0]), 0] < 0)
    for t in TASKS:
        K = KIN[(s, t)]; clamp = task_geo(s, t)['clamp']
        late = -(K[:, 4] - K[:, 3])          # mm frame is positive-rightward; flip to the clamp frame (positive = leftward)
        ok = np.isfinite(late)
        rr.append(st.pearsonr(clamp[ok], late[ok])[0]); sl.append(np.polyfit(clamp[ok], late[ok], 1)[0])
f = lambda x: (np.mean(x), np.std(x, ddof=1))
print('stop beyond target: %.1f mm (SD across participants %.1f); stopped short on %.1f%% of trials' % (*f(per['stop']), 100 * np.concatenate(short).mean()))
print('movement time %.0f ms (SD %.0f); peak velocity %.0f mm/s (SD %.0f)' % (*f(per['mt']), *f(per['pv'])))
print('|direction at target - direction at 50 mm|: %.2f deg (SD %.2f)' % f(per['ddir']))
print('late change vs clamp: mean within-session r = %.2f; slope %.3f deg/deg (%.2f deg at the 10-deg peak)' % (np.mean(rr), np.mean(sl), 10 * np.mean(sl)))

print('================ POINTS AND HIT RATES (recomputed from the on-screen geometry)')
for t in TASKS:
    pts = ADD['points'][t][:, 0]; hit = []
    for s in SUBJ:
        gg = task_geo(s, t); w = gg['conf']
        err = gg['reach_raw'] if t == 'sensorimotor' else gg['report_raw'] - gg['reach_raw']
        hit.append(100 * np.nanmean(np.abs(err) <= w / 2))
    sg = SIG[t]; snr_ = g(t, 'conf_snr'); tt = st.ttest_ind(pts[~sg], pts[sg])
    print('%s: %.0f points (SD %.0f); hit %.1f%% (SD %.1f%%)' % (t, pts.mean(), pts.std(ddof=1), np.mean(hit), np.std(hit, ddof=1)))
    print('   points vs conf SNR r = %.2f, p = %.3f; modulators %.0f (SD %.0f) vs others %.0f (SD %.0f), t(18) = %.2f, p = %.3f'
          % (*st.pearsonr(pts, snr_), pts[sg].mean(), pts[sg].std(ddof=1), pts[~sg].mean(), pts[~sg].std(ddof=1), tt.statistic, tt.pvalue))
d = ADD['points']['sensorimotor'][:, 0] - ADD['points']['motoraware'][:, 0]; tt = st.ttest_rel(ADD['points']['sensorimotor'][:, 0], ADD['points']['motoraware'][:, 0])
print('sensorimotor - motor awareness: %.0f points (SD %.0f), t(19) = %.2f, p = %.4f' % (d.mean(), d.std(ddof=1), tt.statistic, tt.pvalue))

print('================ ARC WIDTH VS. BEST FIXED ARC (Fig. 14)')
for t in TASKS:
    arc = np.array([task_geo(s, t)['conf'].mean() for s in SUBJ]); best = ADD['points'][t][:, 5]
    print('%s: %d of 20 set smaller arcs than the best fixed width (mean %.1f vs %.1f deg)' % (t, (arc < best).sum(), arc.mean(), best.mean()))

print('================ SPECTRA AND CLASSIFICATION (Fig. 5, Supplemental Table S1)')
t = 'sensorimotor'
print('sensorimotor conf SNR: P2 %.1f, P19 %.1f' % (g(t, 'conf_snr')[1], g(t, 'conf_snr')[18]))
for t in TASKS:
    q = bh(g(t, 'conf_p')); rq = bh(g(t, 'rect_p')); a, b = q < .01, rq < .01
    print('%s: Fourier FDR-significant %s; rectified-fit significant %s; agree for %d of 20; disagree: %s'
          % (t, (np.where(a)[0] + 1).tolist(), (np.where(b)[0] + 1).tolist(), (a == b).sum(),
             ['P%d (q %.3f vs rect q %.3f)' % (i + 1, q[i], rq[i]) for i in np.where(a != b)[0]]))
    p = g(t, 'conf_p'); unc = (p < .01) & ~a
    if unc.any(): print('   significant before correction only: %s' % ['P%d p=%.3f q=%.3f' % (i + 1, p[i], q[i]) for i in np.where(unc)[0]])

print('================ REPORTED HAND DIRECTION (motor-awareness task, Fig. 10A)')
t = 'motoraware'; rs = bh(g(t, 'rep_p')) < .01; ra = g(t, 'rep_amp'); L = ADD['report']['LAG']
print('report component significant (FDR) for %d of 20 (not: %s)' % (rs.sum(), (np.where(~rs)[0] + 1).tolist()))
print('amplitude: report %.2f vs reach %.2f deg; range among significant %.1f-%.1f' % (ra.mean(), g(t, 'reach_amp').mean(), ra[rs].min(), ra[rs].max()))
near = rs & (np.abs(L) <= 2.5)
print('%d of %d report lags within 2.5 trials of zero (mean %.1f, SD %.1f)' % (near.sum(), rs.sum(), L[near].mean(), L[near].std(ddof=1)))
for nm in ['hand', 'mixed']:
    m = ADD['report']['grp'] == nm; Lw = np.where(L > 10, L - 20, L)
    print('%s group: %s, lags %s' % (nm, (np.where(m)[0] + 1).tolist(), np.round(L[m] if nm == 'hand' else Lw[m], 1)))
