"""Per-participant Fourier amplitudes, lags, permutation tests (20,000 shuffles), spectral SNR and the
rectified-sinusoid fit of confidence (Eq. 4). Writes results/fourier.pkl."""
from common import *
import pickle
import scipy.stats as st
rng=np.random.default_rng(1)
NP=20000
def perm_amp(x,k,nperm=NP):
    x=x-x.mean(); obs=2*abs(np.fft.fft(x)[k])/len(x)
    S=np.array([rng.permutation(x) for _ in range(nperm)])
    null=2*np.abs(np.fft.fft(S,axis=1)[:,k])/len(x)
    return obs,(np.sum(null>=obs)+1)/(nperm+1),null
t_=np.arange(240); 
PH=np.linspace(0,np.pi,90,endpoint=False)
BAS=np.array([np.abs(np.sin(2*np.pi*12*t_/240-p)) for p in PH])  # 90x240
def rect_fit(c):
    # returns best b, phi, R2 (free a,b), sign of b kept
    best=None; cc=c-c.mean(); sst=np.sum(cc**2)
    for i,bv in enumerate(BAS):
        bvc=bv-bv.mean(); b=np.dot(bvc,cc)/np.dot(bvc,bvc); r2=b*b*np.dot(bvc,bvc)/sst
        if best is None or r2>best[2]: best=(b,PH[i],r2)
    return best
def rect_perm(c,nperm=4000):
    b,phi,r2=rect_fit(c); cc=c-c.mean()
    Bc=BAS-BAS.mean(1,keepdims=True); den=np.sum(Bc**2,1)
    S=np.array([rng.permutation(cc) for _ in range(nperm)])
    proj=S@Bc.T  # nperm x 90
    r2n=np.max(proj**2/den,axis=1)/np.sum(cc**2)
    return b,phi,r2,(np.sum(r2n>=r2)+1)/(nperm+1)
R={}
for s in SUBJ:
    for t in ['sensorimotor','motoraware']:
        d=task(s,t); o={}
        o['reach_amp'],o['reach_p'],_=perm_amp(d['reach'],12)
        o['conf_amp'],o['conf_p'],nullc=perm_amp(d['conf'],24)
        o['conf_nullmean']=nullc.mean(); o['reach_snr']=snr(d['reach'],12); o['conf_snr']=snr(d['conf'],24)
        o['reach_lag']=lag12(d['reach'],d['clamp']); o['conf_lag']=lag24(d['conf'],d['clamp'])
        o['rect_b'],o['rect_phi'],o['rect_r2'],o['rect_p']=rect_perm(d['conf'])
        o['conf_resid_sd']=np.std(d['conf']-d['conf'].mean()-0)  # raw SD
        o['reach_rmsamp']=np.sqrt(np.mean(d['reach']**2))/.707
        if t=='motoraware':
            o['rep_amp'],o['rep_p'],_=perm_amp(d['report'],12); o['rep_snr']=snr(d['report'],12); o['rep_lag']=lag12(d['report'],d['clamp'])
            # replicate lab's (buggy) null: report amplitude vs shuffled CONFIDENCE amplitude
            x=d['report']-d['report'].mean(); obs=abs(np.fft.fft(x)[12]); S=np.array([rng.permutation(d['conf']-d['conf'].mean()) for _ in range(5000)])
            o['rep_p_labbug']=np.mean(np.abs(np.fft.fft(S,axis=1)[:,12])>obs)
        o['points']=d['points'].sum()
        R[(s,t)]=o
    print(s,end=' ',flush=True)
save(R,'fourier.pkl'); print()
