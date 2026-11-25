"""Group permutation test of confidence amplitude, the |clamp| vs |report| regressions, and the
simulation asking whether weak adaptation could hide confidence modulation."""
from common import *
import pickle
A = data()
import scipy.stats as st
R=load('fourier.pkl')
rng=np.random.default_rng(7)
def g(t,k): return np.array([R[(s,t)][k] for s in SUBJ])
def ols(y,X):
    X=np.c_[np.ones(len(y)),X]; b,_,_,_=np.linalg.lstsq(X,y,rcond=None); res=y-X@b; n,k=X.shape
    s2=res@res/(n-k); se=np.sqrt(np.diag(s2*np.linalg.inv(X.T@X))); return b,2*st.t.sf(abs(b/se),n-k),res
# hit rate
for t in ['sensorimotor','motoraware']:
    print(t,'pointsTest hit%%: %.1f'%(100*np.mean([A[s][t]['pointsTest']/240 for s in SUBJ])))
# MA: clamp beyond report
cnt=0; L=[]
for i,s in enumerate(SUBJ):
    d=task(s,'motoraware'); b,p,_=ols(d['conf'],np.c_[np.abs(d['clamp']),np.abs(d['report'])]); L.append((b[1],p[1],b[2],p[2]))
L=np.array(L); sgm=bh(g('motoraware','conf_p'))<.01
print('MA |clamp| beyond |report| p<.05:',[i+1 for i in range(20) if L[i,1]<.05], '; among conf-sig:',np.sum((L[:,1]<.05)&sgm),'of',sgm.sum())
print('MA |report| beyond |clamp| p<.05:',[i+1 for i in range(20) if L[i,3]<.05], '; among conf-sig:',np.sum((L[:,3]<.05)&sgm),'of',sgm.sum(), 'mean coef |report| %.3f deg/deg, |clamp| %.3f'%(L[:,2].mean(),L[:,0].mean()))
# |report| 24-cycle content: is |report| periodic?
# Group-level test via permutation of the mean amplitude
for t in ['sensorimotor','motoraware']:
    nulls=[]
    for s in SUBJ:
        c=task(s,t)['conf']; c=c-c.mean(); S=np.array([rng.permutation(c) for _ in range(5000)]); nulls.append(2*np.abs(np.fft.fft(S,axis=1)[:,24])/240)
    nm=np.mean(nulls,axis=0); obs=g(t,'conf_amp').mean(); print(t,'group mean conf amp %.3f; null mean %.3f; p=%.5f'%(obs,nm.mean(),(np.sum(nm>=obs)+1)/(len(nm)+1)))
# Simulation (SM): for each non-sig participant, simulate confidence using the average cue weights of the
# significant participants (|clamp| and |clamp-hand|, in deg arc per deg) + the participant's own residual noise.
for t in ['sensorimotor','motoraware']:
    sg=bh(g(t,'conf_p'))<.01; Wt=[]
    for i,s in enumerate(SUBJ):
        if not sg[i]: continue
        d=task(s,t); b,p,_=ols(d['conf'],np.c_[np.abs(d['clamp']),np.abs(d['clamp']-d['reach'])]); Wt.append(b[1:])
    Wm=np.mean(Wt,axis=0); print(t,'mean weights sig (|clamp|, |clamp-hand|):',np.round(Wm,3))
    rates=[]
    for i,s in enumerate(SUBJ):
        if sg[i]: continue
        d=task(s,t); sig_=Wm[0]*np.abs(d['clamp'])+Wm[1]*np.abs(d['clamp']-d['reach'])
        noise=d['conf']-d['conf'].mean(); hits=0; nsim=200
        for k in range(nsim):
            y=sig_+rng.permutation(noise); y=y-y.mean(); obs=2*abs(np.fft.fft(y)[24])/240
            S=np.array([rng.permutation(y) for _ in range(500)]); nl=2*np.abs(np.fft.fft(S,axis=1)[:,24])/240
            hits+= (np.sum(nl>=obs)+1)/501 < .01
        rates.append(hits/nsim); print('  P%d reach amp %.1f detect rate %.2f'%(i+1,R[(s,t)]['reach_amp'],hits/nsim))
    print(' mean detection rate %.2f'%np.mean(rates))
