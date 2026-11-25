"""Proprioceptive localization: fit sigma_m and sigma_p for each participant from the 80 localization
trials (trials 21-60 of each session), using the sign-corrected reported direction.
Writes results/sigma.pkl  {initials: (sigma_m, sigma_p)}."""
import numpy as np
from common import *
res_ = {}
for i, s in enumerate(SUBJ):
    r, p = locgeo(s); res_[s] = fit_sigma(r, p)
    print('P%-2d n=%d  sigma_m %.1f  sigma_p %.1f' % (i + 1, len(r), *res_[s]))
v = np.array([res_[s] for s in SUBJ])
print('mean sigma_m %.2f (SD %.2f), sigma_p %.2f (SD %.2f)' % (v[:, 0].mean(), v[:, 0].std(ddof=1), v[:, 1].mean(), v[:, 1].std(ddof=1)))
save(res_, 'sigma.pkl')
