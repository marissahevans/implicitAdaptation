"""Group-level statistics: FDR-corrected classification, cross-task overlap (Fisher test) and
correlations, adaptation vs. modulation, points, proprioceptive uncertainty vs. adaptation, report lags."""
from common import *
import pickle

import scipy.stats as st
R=load('fourier.pkl'); R2=load('cues.pkl')
sig=load('sigma.pkl'); SP=np.array([sig[s][1] for s in SUBJ]); SM_=np.array([sig[s][0] for s in SUBJ])
def g(t,k): return np.array([R[(s,t)][k] for s in SUBJ])
def ols(y,X):
    X=np.c_[np.ones(len(y)),X]; b,_,_,_=np.linalg.lstsq(X,y,rcond=None); res=y-X@b; n,k=X.shape
    s2=res@res/(n-k); se=np.sqrt(np.diag(s2*np.linalg.inv(X.T@X))); return b,2*st.t.sf(abs(b/se),n-k)
S={};
for t in ['sensorimotor','motoraware']:
    S[t]=bh(g(t,'conf_p'))<.01
print('FDR sig SM',np.where(S['sensorimotor'])[0]+1,' MA',np.where(S['motoraware'])[0]+1)
a,b=S['sensorimotor'],S['motoraware']; tab=[[np.sum(a&b),np.sum(a&~b)],[np.sum(~a&b),np.sum(~a&~b)]]
print('2x2',tab,'Fisher p=%.3f'%st.fisher_exact(tab)[1])
a0=g('sensorimotor','conf_p')<.01; b0=g('motoraware','conf_p')<.01; tab0=[[np.sum(a0&b0),np.sum(a0&~b0)],[np.sum(~a0&b0),np.sum(~a0&~b0)]]; print('uncorrected 2x2',tab0,'p=%.3f'%st.fisher_exact(tab0)[1])
for k in ['conf_snr','conf_amp','rect_r2']:
    x=g('sensorimotor',k);y=g('motoraware',k); print('cross-task %s spearman rho=%.2f p=%.4f; pearson r=%.2f p=%.4f'%(k,*st.spearmanr(x,y),*st.pearsonr(x,y)))
W1=R2['sensorimotor']['W'];W2=R2['motoraware']['W']
print('cross-task |clamp| weight r=%.2f p=%.4f; |hand| weight r=%.2f p=%.4f'%(*st.pearsonr(W1[:,0],W2[:,0]),*st.pearsonr(W1[:,1],W2[:,1])))
print('reach Fourier amp cross-task r=%.2f p=%.4f ; rms-amp r=%.2f p=%.4f (r^2 %.2f)'%(*st.pearsonr(g('sensorimotor','reach_amp'),g('motoraware','reach_amp')),*st.pearsonr(g('sensorimotor','reach_rmsamp'),g('motoraware','reach_rmsamp')),st.pearsonr(g('sensorimotor','reach_rmsamp'),g('motoraware','reach_rmsamp'))[0]**2))
for t in ['sensorimotor','motoraware']:
    ra=g(t,'reach_amp'); cs=g(t,'conf_snr'); sg=S[t]
    print('--',t)
    print(' reach amp mean %.2f (SD %.2f); rms-amp mean %.2f'%(ra.mean(),ra.std(ddof=1),g(t,'reach_rmsamp').mean()))
    print(' reach amp vs conf SNR: r=%.2f p=%.3f; spearman %.2f p=%.3f'%(*st.pearsonr(ra,cs),*st.spearmanr(ra,cs)))
    print(' reach amp vs conf amp: r=%.2f p=%.3f'%st.pearsonr(ra,g(t,'conf_amp')))
    tt=st.ttest_ind(ra[sg],ra[~sg]); print(' reach amp sig %.2f vs non %.2f t(18)=%.2f p=%.3f'%(ra[sg].mean(),ra[~sg].mean(),tt.statistic,tt.pvalue))
    sd=np.array([np.std(task(s,t)['conf'],ddof=1) for s in SUBJ]); tt=st.ttest_ind(sd[sg],sd[~sg]); print(' conf SD sig %.2f vs non %.2f t=%.2f p=%.3f'%(sd[sg].mean(),sd[~sg].mean(),tt.statistic,tt.pvalue))
    mc=np.array([np.mean(task(s,t)['conf']) for s in SUBJ]); print(' mean arc all %.2f; sig %.2f non %.2f'%(mc.mean(),mc[sg].mean(),mc[~sg].mean()))
    pts=g(t,'points'); print(' points mean %.2f SD %.2f; sig %.2f (%.2f) non %.2f (%.2f) t=%.2f p=%.4f'%(pts.mean(),pts.std(ddof=1),pts[sg].mean(),pts[sg].std(ddof=1),pts[~sg].mean(),pts[~sg].std(ddof=1),*st.ttest_ind(pts[sg],pts[~sg])))
    print(' points vs conf SNR r=%.2f p=%.3f'%st.pearsonr(cs,pts))
    sg0=g(t,'conf_p')<.01; print(' points t (uncorrected groups) t=%.2f p=%.4f'%st.ttest_ind(pts[sg0],pts[~sg0]))
    print(' sigma_p vs reach rms-amp r=%.3f p=%.3f r2=%.3f ; vs Fourier amp r=%.3f p=%.3f'%(*st.pearsonr(SP,g(t,'reach_rmsamp')),st.pearsonr(SP,g(t,'reach_rmsamp'))[0]**2,*st.pearsonr(SP,ra)))
    print(' sigma_p sig vs non t=%.2f p=%.3f (uncorr groups t=%.2f)'%(*st.ttest_ind(SP[sg],SP[~sg]),st.ttest_ind(SP[sg0],SP[~sg0]).statistic))
    cl=g(t,'conf_lag'); print(' conf lag sig mean %.2f SD %.2f'%(cl[sg].mean(),cl[sg].std(ddof=1)))
    print(' group mean conf amp %.3f vs null mean %.3f'%(g(t,'conf_amp').mean(),g(t,'conf_nullmean').mean()))
d=g('sensorimotor','points')-g('motoraware','points'); print('SM-MA points diff %.2f SD %.2f t(19)=%.2f p=%.2g'%(d.mean(),d.std(ddof=1),*st.ttest_rel(g('sensorimotor','points'),g('motoraware','points'))))
rl=g('motoraware','rep_lag'); rp=bh(g('motoraware','rep_p'))<.01; print('report lag (sig) M %.2f SD %.2f n=%d; <10: %d'%(rl[rp].mean(),rl[rp].std(ddof=1),rp.sum(),np.sum(rl[rp]<10)))
print('report lags', ' '.join('%d:%.1f'%(i+1,x) for i,x in enumerate(rl)))
cl=g('motoraware','conf_lag'); both=rp&S['motoraware']; print('conf lag vs report lag (both sig, n=%d) r=%.2f p=%.3f'%(both.sum(),*st.pearsonr(cl[both],rl[both])))
print('report amp', ' '.join('%.1f'%x for x in g('motoraware','rep_amp')))
