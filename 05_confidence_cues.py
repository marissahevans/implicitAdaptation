"""Trial-by-trial correlation of confidence with |clamp - hand| and AIC comparison of cue models
(|clamp|, |hand|, |clamp - hand|, and in the motor-awareness task |report|, |report - hand|).
Writes results/cues.pkl (Supplemental Table S2)."""
from common import *
import pickle

import scipy.stats as st, itertools
R=load('fourier.pkl')
sig=load('sigma.pkl'); SP=np.array([sig[s][1] for s in SUBJ])
def ols(y,X):
    X=np.c_[np.ones(len(y)),X]; b,_,_,_=np.linalg.lstsq(X,y,rcond=None); res=y-X@b; n,k=X.shape
    s2=res@res/(n-k); se=np.sqrt(np.diag(s2*np.linalg.inv(X.T@X))); tval=b/se; p=2*st.t.sf(abs(tval),n-k)
    aic=n*np.log(res@res/n)+2*(k+1); return b,se,p,aic
out={}
for t in ['sensorimotor','motoraware']:
    g=lambda k: np.array([R[(s,t)][k] for s in SUBJ])
    q=bh(g('conf_p')); sigc=q<.01
    print('\n=====',t)
    # mismatch correlation
    rr=[];pp=[];rre=[];pre=[];best=[];W=[];repcoef=[]
    for s in SUBJ:
        d=task(s,t); mm=np.abs(d['clamp']-d['reach']); r,p=st.pearsonr(d['conf'],mm); rr.append(r); pp.append(p)
        preds={'|clamp|':np.abs(d['clamp']),'|hand|':np.abs(d['reach']),'|clamp-hand|':mm}
        if t=='motoraware':
            preds['|report|']=np.abs(d['report']); preds['|report-hand|']=np.abs(d['report']-d['reach'])
            r2,p2=st.pearsonr(d['conf'],preds['|report-hand|']); rre.append(r2); pre.append(p2)
            b,se,pb,_=ols(d['conf'],np.c_[st.zscore(preds['|clamp|']),st.zscore(preds['|report|'])]); repcoef.append((b[2],pb[2]))
        names=list(preds); models={}
        for k in [1,2]:
            for comb in itertools.combinations(names,k):
                X=np.c_[[st.zscore(preds[c]) for c in comb]].T; models[comb]=ols(d['conf'],X)[3]
        aic0=len(d['conf'])*np.log(np.var(d['conf']))+4
        bm=min(models,key=models.get); best.append((bm,models[bm]-aic0,models))
        b,se,pb,_=ols(d['conf'],np.c_[st.zscore(np.abs(d['clamp'])),st.zscore(np.abs(d['reach']))]); W.append(b[1:])
    rr=np.array(rr);pp=np.array(pp); qq=bh(pp)
    print('mismatch r:', ' '.join('%.3f'%x for x in rr)); print('r^2:', ' '.join('%.3f'%x for x in rr**2))
    print('sig uncorrected p<.05:',[i+1 for i in range(20) if pp[i]<.05],' FDR q<.05:',[i+1 for i in range(20) if qq[i]<.05])
    if t=='motoraware':
        rre=np.array(rre);pre=np.array(pre); print('report-error corr sig p<.05:',[i+1 for i in range(20) if pre[i]<.05],'r',' '.join('%.2f'%x for x in rre),' FDR',[i+1 for i in range(20) if bh(pre)[i]<.05])
        rc=np.array(repcoef); print('|report| beyond |clamp| p<.05 in:',[i+1 for i in range(20) if rc[i,1]<.05 ], 'coef sign', np.sign(rc[:,0]).astype(int))
    # cue regression summary
    from collections import Counter
    print('best model (dAIC vs intercept-only):'); 
    for i,(bm,da,_) in enumerate(best): print('  P%d %s %.1f %s'%(i+1,'+'.join(bm),da,'*' if sigc[i] else ''))
    c=Counter(['+'.join(b[0]) for i,b in enumerate(best) if sigc[i]]); print('among sig:',c)
    out[t]=dict(rr=rr,pp=pp,best=best,W=np.array(W),rre=rre if t=='motoraware' else None,repcoef=repcoef)
save(out,'cues.pkl')
