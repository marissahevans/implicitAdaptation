"""Values reported in the original submission, recomputed from the lab-processed files."""
import sys, os; sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from common import *
import pickle
A = data()
import scipy.stats as st
sm=np.array([A[s]['sigmaFit']['sigMmarg'] for s in SUBJ]); sp=np.array([A[s]['sigmaFit']['sigPmarg'] for s in SUBJ])
print('sigma_m %.2f (%.2f) sigma_p %.2f (%.2f)'%(sm.mean(),sm.std(ddof=1),sp.mean(),sp.std(ddof=1)))
for t in ['sensorimotor','motoraware']:
    L=[];C=[];pts=[];hit=[];AR=[];AC=[];rms=[]
    for s in SUBJ:
        d=task(s,t); L.append(lag12(d['reach'],d['clamp'])); C.append(lag24(d['conf'],d['clamp']))
        pts.append(d['points'].sum()); AR.append(amp(d['reach'],12)); AC.append(amp(d['conf'],24)); rms.append(np.sqrt(np.mean(d['reach']**2))/.707)
        x = d['report'] if t=='motoraware' else 0
        hit.append(np.mean(d['points']>0))
    L=np.array(L);print(t,'reach lag %.2f (%.2f) range %.2f-%.2f'%(L.mean(),L.std(ddof=1),L.min(),L.max()))
    print('  points %.2f (%.2f); hit%% %.1f (%.1f)'%(np.mean(pts),np.std(pts,ddof=1),100*np.mean(hit),100*np.std(hit,ddof=1)))
    print('  reach Fourier amp mean %.2f; rms-amp mean %.2f'%(np.mean(AR),np.mean(rms)))
    cp=np.array([A[s]['confPermute']['permutePval'][0 if t=='motoraware' else 1][24] for s in SUBJ])
    print('  saved conf p<.01 at 24cyc: n=%d'%(cp<.01).sum(), ' sig subj:',[s for s,p in zip(SUBJ,cp) if p<.01])
    print('  conf lag (sig only) %.2f (%.2f)'%(np.array(C)[cp<.01].mean(),np.array(C)[cp<.01].std(ddof=1)))
    print('  saved signifFreq', [int(np.atleast_1d(A[s]['confPermute']['signifFreq'])[0 if t=='motoraware' else 1]) for s in SUBJ], A[SUBJ[0]]['confPermute'].get('confPval'))
