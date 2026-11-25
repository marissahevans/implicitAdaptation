"""Compares the lab script clampFitSigmaP.m (as written; reproduces the saved sigmaFit.mat values) with
variants of the localization fit. Uses the processed (sign-inverted) report, as the lab script did."""
import sys, os; sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from common import *
import pickle
A = data()
import io, contextlib
# files used per participant (exactly as listed in clampFitSigmaP.m)
SCRIPT={'OY':['S1_2025-03-04_14-26','S3_2025-03-07_16-55'],'CK':['S2_2025-03-06_17-01','S1_2025-03-06_15-50'],'MG':['S1_2025-03-24_14-48','S2_2025-03-27_15-00'],
'SX':['S1_2025-03-26_15-50','S2_2025-04-10_15-00'],'ML':['S1_2025-03-25_14-59','S2_2025-03-25_16-34'],'LL':['S1_2025-03-27_12-50','S2_2025-03-28_14-45'],
'LN':['S1_2025-04-10_16-00','S2_2025-04-14_15-46'],'EN':['S1_2025-04-15_15-57','S2_2025-04-15_17-07'],'NK':['S1_2025-04-17_15-29','S2_2025-04-17_16-20'],
'SH':['S1_2025-04-25_15-16','S2_2025-04-25_16-30'],'HP':['S1_2025-04-29_09-01','S2_2025-04-29_09-45'],'DT':['S1_2025-04-28_13-01','S2_2025-04-29_13-59'],
'MH':['S1_2025-04-24_16-06','S2_2025-04-30_15-55'],'TC':['S1_2025-05-02_15-05','S2_2025-05-02_16-30'],'ET':['S1_2025-04-30_13-59','S2_2025-05-07_13-59'],
'HH':['S1_2025-05-06_16-00','S2_2025-05-07_16-00'],'HL':['S1_2025-04-29_13-02','S2_2025-05-09_12-14'],'JH':['S1_2025-05-07_15-01','S2_2025-05-12_13-58'],
'AS':['S1_2025-05-09_15-12','S2_2025-05-12_15-03'],'NM':['S1_2025-05-13_16-14','S2_2025-05-13_17-19']}
def data(s,tr=(20,60),out=False):
    r=[];p=[]
    for t in SCRIPT[s]:
        e=get(A[s]['raw'],t)['e']; r+=list(e.endPtAngle[tr[0]:tr[1]]-90); p+=list(-e.reportAngle[tr[0]:tr[1]])
    r=np.array(r);p=np.array(p)
    if s=='EN' or out: r[np.abs(r)>30]=r.mean(); p[np.abs(p)>30]=p.mean()
    return r,p
m=np.arange(1,40.01,.1)
def fit(reach,report,correct=False,stat='mode'):
    M,P=np.meshgrid(m,m,indexing='ij'); rm=1/M**2; rp=1/P**2; k=rp/(rp+rm); N=len(reach); sd=k*P
    c=0.5 if correct else 1.0
    LLe=-c*N*np.log(2*np.pi)-2*c*N*np.log(M)-np.sum(reach**2)/(2*M**2)
    q=np.sum(report**2)-2*k*np.sum(report*reach)+k**2*np.sum(reach**2)
    LLi=-c*N*np.log(2*np.pi)-2*c*N*np.log(sd)-q/(2*sd**2)
    LL=LLe+LLi; Pn=np.exp(LL-LL.max()); mm=Pn.sum(1); pm=Pn.sum(0)
    if stat=='mode': return m[np.argmax(mm)],m[np.argmax(pm)]
    if stat=='mean': return np.sum(m*mm)/mm.sum(),np.sum(m*pm)/pm.sum()
    i=np.unravel_index(np.argmax(LL),LL.shape); return m[i[0]],m[i[1]]
def summ(lab,f):
    v=np.array([f(s) for s in SUBJ]); print('%-58s σm %.2f (%.2f)  σp %.2f (%.2f)'%(lab,v[:,0].mean(),v[:,0].std(ddof=1),v[:,1].mean(),v[:,1].std(ddof=1))); return v
print('target in paper:                                           σm 3.99 (1.37)  σp 7.16 (3.65)')
base=summ('script as written (trials 21:60, both sessions)',lambda s: fit(*data(s)))
saved=np.array([[A[s]['sigmaFit']['sigMmarg'],A[s]['sigmaFit']['sigPmarg']] for s in SUBJ]); print('   matches saved sigmaFit.mat for all 20:',np.allclose(base,saved))
summ('script likelihood corrected (Gaussian 1/2 factors)',lambda s: fit(*data(s),correct=True))
summ('joint maximum instead of marginal modes',lambda s: fit(*data(s),stat='joint'))
summ('marginal means instead of modes',lambda s: fit(*data(s),stat='mean'))
summ('trials 1:60 (incl. 20 practice trials with feedback)',lambda s: fit(*data(s,(0,60))))
summ('first session only, trials 21:60',lambda s: (lambda r,p: fit(r[:40],p[:40]))(*data(s)))
summ('|x|>30 outlier rule applied to everyone',lambda s: fit(*data(s,out=True)))
def cen(s):
    r,p=data(s); return fit(r-r.mean(),p-p.mean())
summ('reach and report mean-centred per participant',cen)
def cen2(s):
    r,p=[],[]
    for t in SCRIPT[s]:
        e=get(A[s]['raw'],t)['e']; a=e.endPtAngle[20:60]-90; b=-e.reportAngle[20:60]; r+=list(a-a.mean()); p+=list(b-b.mean())
    r=np.array(r);p=np.array(p)
    if s=='EN': r[np.abs(r)>30]=0; p[np.abs(p)>30]=0
    return fit(r,p)
summ('centred within each session',cen2)
# per-participant data check
print('\nper participant: n trials, mean reach, SD reach, mean report, SD report, any |x|>30')
for i,s in enumerate(SUBJ):
    r,p=data(s); print('P%-2d %s n=%d reach %.1f±%.1f report %.1f±%.1f  outliers %d  fit %.1f/%.1f'%(i+1,s,len(r),r.mean(),r.std(),p.mean(),p.std(),np.sum(np.abs(np.r_[r,p])>30),*base[i]))
import scipy.stats as st
R=load('fourier.pkl')
corr=np.array([fit(*data(s),correct=True) for s in SUBJ])
print('\nratio corrected/script: σm %.3f σp %.3f (√2 = 1.414)'%(np.mean(corr[:,0]/base[:,0]),np.mean(corr[:,1]/base[:,1])))
for lab,v in [('script',base[:,1]),('corrected',corr[:,1])]:
    for t in ['sensorimotor','motoraware']:
        ra=np.array([R[(s,t)]['reach_amp'] for s in SUBJ]); sg=bh(np.array([R[(s,t)]['conf_p'] for s in SUBJ]))<.01
        print('%s σp vs reach amp %s: r=%.2f p=%.2f; σp mod vs not t=%.2f p=%.2f'%(lab,t[:5],*st.pearsonr(v,ra),*st.ttest_ind(v[sg],v[~sg])))
print('OY outliers:',[(round(x,1)) for x in np.r_[data('OY')] .ravel() if abs(x)>30], 'CK:',[round(x,1) for x in np.r_[data('CK')].ravel() if abs(x)>30])
