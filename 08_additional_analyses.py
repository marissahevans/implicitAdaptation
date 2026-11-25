"""Additional analyses added in revision: points benchmarks (Fig. 14), report weights (Fig. 11),
state-space model (Fig. 15), task order and session halves (Supplemental Figure S6), and two control
analyses (starting arc width; time to set the arc). Writes results/additional.pkl."""
from common import *
import pickle
import scipy.stats as st
from scipy.optimize import minimize
R=load('fourier.pkl'); SIGP=load('sigma.pkl')
SP=np.array([SIGP[s][1] for s in SUBJ]); SMm=np.array([SIGP[s][0] for s in SUBJ]); K=(1/SP**2)/(1/SP**2+1/SMm**2)
def g(t,k): return np.array([R[(s,t)][k] for s in SUBJ])
SIG={t:bh(g(t,'conf_p'))<.01 for t in ['sensorimotor','motoraware']}
SNR={t:g(t,'conf_snr') for t in SIG}
OUT={}
def ols(y,X):
    X=np.c_[np.ones(len(y)),X]; b=np.linalg.lstsq(X,y,rcond=None)[0]; res=y-X@b; n,k=X.shape
    s2=res@res/(n-k); se=np.sqrt(np.diag(s2*np.linalg.inv(X.T@X))); return b,2*st.t.sf(abs(b/se),n-k),se
P0={'sensorimotor':(10.147,0.5),'motoraware':(10.298,1.0)}
def pay(w,t): a,b=P0[t]; return np.clip(a-b*w,0,10)
def pts(err,w,t): return np.where(np.abs(err)<=w/2,pay(w,t),0.0)
W=np.arange(0.4,40.01,0.2)
print('================ 1. POINTS BENCHMARKS')
PB={}
for t in ['sensorimotor','motoraware']:
    rows=[]
    for i,s in enumerate(SUBJ):
        gg=task_geo(s,t); w=gg['conf']; cl=np.abs(gg['clamp'])
        err=gg['reach_raw'] if t=='sensorimotor' else gg['report_raw']-gg['reach_raw']
        ok=np.isfinite(err); err=np.where(ok,err,np.nanmean(err))
        actual=pts(err,w,t).sum()
        b=np.polyfit(cl,w,1)[0]; w2=np.maximum(w-b*(cl-cl.mean()),0.4); noclamp=pts(err,w2,t).sum()
        best=max(pts(err,wc,t).sum() for wc in W)
        # error-aware: knows the predictable 12-cycle component of the error + residual SD
        tt=np.arange(240); Xs=np.c_[np.ones(240),np.sin(2*np.pi*12*tt/240),np.cos(2*np.pi*12*tt/240)]
        bb=np.linalg.lstsq(Xs,err,rcond=None)[0]; mu=Xs@bb; sd=np.std(err-mu)
        EV=np.array([(st.norm.cdf((wc/2-mu)/sd)-st.norm.cdf((-wc/2-mu)/sd))*pay(wc,t) for wc in W])  # len(W) x 240
        wopt=W[np.argmax(EV,axis=0)]; aware=pts(err,wopt,t).sum()
        EVc=np.array([(st.norm.cdf((wc/2-err.mean())/np.std(err))-st.norm.cdf((-wc/2-err.mean())/np.std(err)))*pay(wc,t) for wc in W]); wc_=W[np.argmax(EVc)]
        rows.append([actual,noclamp,best,aware,b,wc_,np.mean(wopt),np.std(wopt)])
    r=np.array(rows); PB[t]=r
    print(t,'means: actual %.0f | clamp component removed %.0f | best fixed arc %.0f | error-aware ideal %.0f'%tuple(r[:,:4].mean(0)))
    d=r[:,1]-r[:,0]; print('  removing clamp component: +%.1f points (SD %.1f), t(19)=%.2f p=%.4f; in modulators +%.1f, others +%.1f'%(d.mean(),d.std(ddof=1),*st.ttest_rel(r[:,1],r[:,0]),d[SIG[t]].mean(),d[~SIG[t]].mean()))
    print('  gain vs SNR r=%.2f p=%.3f'%st.pearsonr(SNR[t],d))
    d2=r[:,2]-r[:,0]; print('  best fixed - actual: %.1f (SD %.1f) t=%.2f p=%.4f; actual as %% of best fixed: %.0f%%'%(d2.mean(),d2.std(ddof=1),*st.ttest_rel(r[:,2],r[:,0]),100*np.mean(r[:,0]/r[:,2])))
    d3=r[:,3]-r[:,2]; print('  error-aware - best fixed: %.1f (SD %.1f) t=%.2f p=%.4f'%(d3.mean(),d3.std(ddof=1),*st.ttest_rel(r[:,3],r[:,2])))
    print('  clamp slope of arc (deg/deg) mean %.2f; ideal arc variation SD within session %.2f deg'%(r[:,4].mean(),r[:,7].mean()))
OUT['points']=PB
print('================ 2. REPORT WEIGHTS')
WH=[];WC=[];LAG=[]
for i,s in enumerate(SUBJ):
    gg=task_geo(s,'motoraware'); rep=gg['report_raw']; ok=np.isfinite(rep)
    b,p,se=ols(rep[ok],np.c_[gg['reach_raw'][ok],gg['clamp'][ok]]); WH.append((b[1],p[1])); WC.append((b[2],p[2]))
    l=R[(s,'motoraware')]['rep_lag']; LAG.append(l-20 if l>15 else l)
WH=np.array(WH);WC=np.array(WC);LAG=np.array(LAG); rs=bh(g('motoraware','rep_p'))<.01
print('w_hand mean %.2f (SD %.2f), sig>0 in %d; w_clamp mean %.2f (SD %.2f), sig>0 in %d, sig<0 in %d'%(WH[:,0].mean(),WH[:,0].std(ddof=1),np.sum((WH[:,1]<.05)&(WH[:,0]>0)),WC[:,0].mean(),WC[:,0].std(ddof=1),np.sum((WC[:,1]<.05)&(WC[:,0]>0)),np.sum((WC[:,1]<.05)&(WC[:,0]<0))))
print('w_hand vs localization k: mean k %.2f; paired t=%.2f p=%.4f; r=%.2f p=%.3f'%(K.mean(),*st.ttest_rel(WH[:,0],K),*st.pearsonr(WH[:,0],K)))
print('w_clamp vs sigma_p r=%.2f p=%.3f; spearman %.2f p=%.3f'%(*st.pearsonr(SP,WC[:,0]),*st.spearmanr(SP,WC[:,0])))
print('w_hand vs sigma_p r=%.2f p=%.3f'%st.pearsonr(SP,WH[:,0]))
print('lags (wrapped -5..15):',' '.join('%d:%.1f'%(i+1,x) for i,x in enumerate(LAG)))
grp=np.where(~rs,'none',np.where(np.abs(LAG)<=2.5,'cursor',np.where((LAG>=8)&(LAG<=13),'hand','mixed')))
for gname in ['cursor','mixed','hand','none']: print('  %s: %s'%(gname,[i+1 for i in range(20) if grp[i]==gname]))
print('w_clamp vs report amp r=%.2f'%st.pearsonr(WC[:,0],g('motoraware','rep_amp'))[0])
print('w_clamp in cursor group mean %.2f; hand group %.2f'%(WC[grp=='cursor',0].mean(),WC[grp=='hand',0].mean()))
print('conf SNR vs w_clamp r=%.2f p=%.3f'%st.pearsonr(SNR['motoraware'],WC[:,0]))
OUT['report']=dict(WH=WH,WC=WC,LAG=LAG,grp=grp,K=K)
print('================ 3. STATE-SPACE MODEL (bounded fit: 0 <= A <= 1, B >= 0)')
from scipy.optimize import minimize
SIG_=SIG
def sim(A_,B_,x0,c):
    x=np.empty(len(c)); x[0]=x0
    for k in range(len(c)-1): x[k+1]=A_*x[k]-B_*c[k]
    return x
SS={};FIT={}
for t in ['sensorimotor','motoraware']:
    rows=[]
    for s in SUBJ:
        gg=task_geo(s,t); y=gg['reach_raw']; c=gg['clamp']
        loss=lambda p: np.sum((y-(sim(p[0],p[1],p[2],c)+p[3]))**2)
        best=None
        for a0 in [0.1,0.4,0.7,0.9,0.98]:
            for b0 in [0.05,0.2,0.5]:
                r_=minimize(loss,[a0,b0,0,y.mean()],method='L-BFGS-B',bounds=[(0,1),(0,2),(-30,30),(-30,30)])
                if best is None or r_.fun<best.fun: best=r_
        A_,B_,x0,bias=best.x; yh=sim(A_,B_,x0,c)+bias; r2=1-np.sum((y-yh)**2)/np.sum((y-y.mean())**2)
        w=2*np.pi/20; H=-B_*np.exp(-1j*w)/(1-A_*np.exp(-1j*w)); rows.append([A_,B_,abs(H),(-np.angle(H)/w)%20,r2]); FIT[(s,t)]=(y,yh,c)
    r=np.array(rows); SS[t]=r
    print(t,'A %.2f (SD %.2f, range %.2f-%.2f, at bound 0: %d, at 1: %d); B %.2f (SD %.2f, %.2f-%.2f); R2 %.2f (range %.2f-%.2f); lag model %.2f'%(r[:,0].mean(),r[:,0].std(ddof=1),r[:,0].min(),r[:,0].max(),np.sum(r[:,0]<.01),np.sum(r[:,0]>.99),r[:,1].mean(),r[:,1].std(ddof=1),r[:,1].min(),r[:,1].max(),r[:,4].mean(),r[:,4].min(),r[:,4].max(),r[:,3].mean()))
    for nm,j in [('A',0),('B',1)]:
        print('  %s vs SNR rho=%.2f p=%.3f r=%.2f p=%.3f | modulators %.2f vs others %.2f t(18)=%.2f p=%.3f | vs sigma_p r=%.2f p=%.3f'%(nm,*st.spearmanr(r[:,j],SNR[t]),*st.pearsonr(r[:,j],SNR[t]),r[SIG[t],j].mean(),r[~SIG[t],j].mean(),*st.ttest_ind(r[SIG[t],j],r[~SIG[t],j]),*st.pearsonr(r[:,j],SP)))
print('cross-task A r=%.2f p=%.4f; B r=%.2f p=%.4f'%(*st.pearsonr(SS['sensorimotor'][:,0],SS['motoraware'][:,0]),*st.pearsonr(SS['sensorimotor'][:,1],SS['motoraware'][:,1])))
OUT['ss']=SS; OUT['ssfit']=FIT
print('================ 4. ORDER AND WITHIN-SESSION')
first=np.array([s in SM_FIRST for s in SUBJ])
for nm,f in [('reach amp',lambda t:g(t,'reach_amp')),('conf SNR',lambda t:np.log(SNR[t])),('conf mean arc',lambda t:np.array([task(s,t)['conf'].mean() for s in SUBJ]))]:
    sm,ma=f('sensorimotor'),f('motoraware')
    s1=np.where(first,sm,ma); s2=np.where(first,ma,sm)
    tt=st.ttest_rel(s1,s2); diff=sm-ma; ti=st.ttest_ind(diff[first],diff[~first]); to=st.ttest_ind((sm+ma)[first],(sm+ma)[~first])
    print('%s: session1 %.2f vs session2 %.2f paired t(19)=%.2f p=%.3f | task SM %.2f vs MA %.2f | order-group main t(18)=%.2f p=%.3f'%(nm,s1.mean(),s2.mean(),tt.statistic,tt.pvalue,sm.mean(),ma.mean(),to.statistic,to.pvalue))
def half_amp(x,k): 
    return [2*abs(np.fft.fft(h-h.mean())[k])/120 for h in (x[:120],x[120:])]
for t in ['sensorimotor','motoraware']:
    ra=np.array([half_amp(task(s,t)['reach'],6) for s in SUBJ]); ca=np.array([half_amp(task(s,t)['conf'],12) for s in SUBJ])
    print(t,'reach amp 1st half %.2f 2nd half %.2f t=%.2f p=%.3f | conf amp 1st %.2f 2nd %.2f t=%.2f p=%.3f (modulators: %.2f vs %.2f p=%.3f)'%(ra[:,0].mean(),ra[:,1].mean(),*st.ttest_rel(ra[:,0],ra[:,1]),ca[:,0].mean(),ca[:,1].mean(),*st.ttest_rel(ca[:,0],ca[:,1]),ca[SIG[t],0].mean(),ca[SIG[t],1].mean(),st.ttest_rel(ca[SIG[t],0],ca[SIG[t],1]).pvalue))
    OUT['halves_'+t]=(ra,ca)
OUT['first']=first
print('================ CONTROL A: starting arc')
for t in ['sensorimotor','motoraware']:
    rr=[];cl=[];cl0=[]
    for s in SUBJ:
        gg=task_geo(s,t); y=gg['conf']; a=gg['arcstart']; c=np.abs(gg['clamp'])
        rr.append(st.pearsonr(a,y)); b,p,_=ols(y,np.c_[c,a]); cl.append((b[1],p[1],b[2],p[2])); b0,p0,_=ols(y,c); cl0.append((b0[1],p0[1]))
    rr=np.array(rr); cl=np.array(cl); cl0=np.array(cl0)
    print(t,'corr(start, final) mean r=%.3f, p<.05 in %d (pos %d); |clamp| coef w/o start %.3f, with start %.3f; |clamp| p<.05: %d -> %d; start coef p<.05 in %d'%(rr[:,0].mean(),np.sum(rr[:,1]<.05),np.sum((rr[:,1]<.05)&(rr[:,0]>0)),cl0[:,0].mean(),cl[:,0].mean(),np.sum(cl0[:,1]<.05),np.sum(cl[:,1]<.05),np.sum(cl[:,3]<.05)))
    print('   modulators |clamp| still p<.05 with start covariate: %d of %d'%(np.sum((cl[:,1]<.05)&SIG[t]),SIG[t].sum()))
    OUT['startA_'+t]=(rr,cl,cl0)
print('================ CONTROL B: confidence-setting time')
for t in ['sensorimotor','motoraware']:
    # choose start->degree scale alpha by best group fit of log time on |final - alpha*start|
    data=[]
    for s in SUBJ:
        gg=task_geo(s,t); T=gg['conftime']; ok=(T>0)&(T<30); data.append((gg,ok))
    def grp_r2(alpha):
        tot=0
        for gg,ok in data:
            y=np.log(gg['conftime'][ok]); trav=np.abs(gg['conf'][ok]-alpha*gg['arcstart'][ok])
            X=np.c_[np.ones(ok.sum()),trav,gg['conf'][ok],gg['arcstart'][ok]]; b=np.linalg.lstsq(X,y,rcond=None)[0]; tot+=np.sum((y-X@b)**2)
        return tot
    al=np.arange(0.2,4.01,0.1); sse=[grp_r2(a) for a in al]; alpha=al[int(np.argmin(sse))]
    res=[]
    for gg,ok in data:
        y=np.log(gg['conftime'][ok]); trav=np.abs(gg['conf'][ok]-alpha*gg['arcstart'][ok]); c=np.abs(gg['clamp'][ok])
        b,p,_=ols(y,np.c_[c,trav,gg['conf'][ok],gg['arcstart'][ok]]); b0,p0,_=ols(y,c); res.append((b[1],p[1],b[2],p[2],b0[1],p0[1]))
    res=np.array(res)
    print(t,'alpha (deg per start unit)=%.1f; median time %.2f s'%(alpha,np.median(np.concatenate([d[0]['conftime'][d[1]] for d in data]))))
    print('   |clamp| alone: mean coef %.4f log-s/deg, t(19) vs 0 = %.2f p=%.3f, p<.05 in %d'%(res[:,4].mean(),*st.ttest_1samp(res[:,4],0),np.sum(res[:,5]<.05)))
    print('   |clamp| with travel/start/final: mean coef %.4f, t(19)=%.2f p=%.3f, p<.05 in %d (pos %d); travel coef mean %.4f p<.05 in %d'%(res[:,0].mean(),*st.ttest_1samp(res[:,0],0),np.sum(res[:,1]<.05),np.sum((res[:,1]<.05)&(res[:,0]>0)),res[:,2].mean(),np.sum(res[:,3]<.05)))
    print('   modulators vs others clamp coef: %.4f vs %.4f t=%.2f p=%.3f'%(res[SIG[t],0].mean(),res[~SIG[t],0].mean(),*st.ttest_ind(res[SIG[t],0],res[~SIG[t],0])))
    OUT['timeB_'+t]=(res,alpha)
save(OUT,'additional.pkl')
