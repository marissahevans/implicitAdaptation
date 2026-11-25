"""FDR-corrected and rectified-sinusoid classification next to the uncorrected and saved lab values."""
import sys, os; sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from common import *
import pickle
A = data()

R=load('fourier.pkl')
for t in ['sensorimotor','motoraware']:
    g=lambda k: np.array([R[(s,t)][k] for s in SUBJ])
    saved=np.array([A[s]['confPermute']['permutePval'][1 if t=='sensorimotor' else 0][24] for s in SUBJ])
    print('==',t)
    print('reach p max', g('reach_p').max(), 'reach FDR sig n', (bh(g('reach_p'))<.01).sum())
    cp=g('conf_p'); q=bh(cp)
    print('conf p (mine)  ', ' '.join('%.4f'%x for x in cp))
    print('conf p (saved) ', ' '.join('%.4f'%x for x in saved))
    print('conf uncorrected sig', [i+1 for i in range(20) if cp[i]<.01], ' n=',(cp<.01).sum())
    print('conf FDR q<.01 sig ', [i+1 for i in range(20) if q[i]<.01], ' n=',(q<.01).sum())
    print('conf FDR q<.05 sig ', [i+1 for i in range(20) if q[i]<.05])
    rp=g('rect_p'); rq=bh(rp)
    print('rect p', ' '.join('%.4f'%x for x in rp)); print('rect FDR<.01', [i+1 for i in range(20) if rq[i]<.01], 'b sign', np.sign(g('rect_b')).astype(int))
    print('conf SNR', ' '.join('%.2f'%x for x in g('conf_snr')))
    if t=='motoraware':
        p=g('rep_p'); print('report p', ' '.join('%.4f'%x for x in p)); print('report uncorr sig',[i+1 for i in range(20) if p[i]<.01],'FDR',[i+1 for i in range(20) if bh(p)[i]<.01])
        print('lab-bug report p sig (<.01) ',[i+1 for i in range(20) if g('rep_p_labbug')[i]<.01])
        sv=np.array([A[s]['reportPermute']['permutePval'][12] for s in SUBJ]); print('saved report p at 12:',[i+1 for i in range(20) if sv[i]<.01], 'saved reportPval', [float(A[s]['reportPermute']['reportPval']) for s in SUBJ][:5])
