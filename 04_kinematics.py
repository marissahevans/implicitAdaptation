"""Reach kinematics from the tablet samples (converted to mm with the calibration points): stopping distance
beyond the target, movement time, peak velocity, and direction at 50 mm vs. at the target radius.
Writes results/kinematics.pkl (columns: stop_mm, MT, peak_vel, dir50, dir_target, cross_angle, endPtAngle, sample_dt)."""
from common import *
import pickle
A = data()
MM=np.array([[23,244],[23,134],[23,27],[238,244],[238,134],[238,27],[446,244],[446,134],[446,27]],float)
def aff(src,dst):  # least-squares affine src->dst, returns function
    X=np.c_[src,np.ones(len(src))]; M,_,_,_=np.linalg.lstsq(X,dst,rcond=None); return lambda p: np.c_[p,np.ones(len(p))]@M
def kin_trials(x,a,b):
    e,d=x['e'],x['d']; cal=d.calibration; wac=np.c_[cal[5],cal[6]].astype(float); scr=np.array(cal[7],float).T
    w2mm=aff(wac[[1,4,5]],MM[[1,4,5]])   # same 3 points as lab code (exact affine)
    w2s=aff(wac,scr); s2w=aff(scr,wac)
    start_s=np.array(e.startPos,float); start_mm=w2mm(s2w(start_s[None]))[0]
    tar_mm=w2mm(s2w(np.array(e.targetLoc,float)[None]))[0]; R=np.linalg.norm(tar_mm-start_mm)
    td=e.tabletData; rows=[]
    for tr in range(a,b+1):
        T=td[td[:,5]==tr]
        if len(T)<4: rows.append([np.nan]*8); continue
        P=w2mm(T[:,:2].astype(float)); t=T[:,3]
        rad=np.linalg.norm(P-start_mm,axis=1); 
        stop=rad[-1]-R
        v=np.linalg.norm(np.diff(P,axis=0),axis=1)/np.diff(t); pv=np.nanmax(v[np.isfinite(v)]) if len(v) else np.nan
        def dir_at(r0):
            i=np.argmax(rad>=r0)
            if rad[i]<r0: return np.nan
            if i==0: q=P[0]
            else:
                f=(r0-rad[i-1])/(rad[i]-rad[i-1]); q=P[i-1]+f*(P[i]-P[i-1])
            dv=q-start_mm; return np.degrees(np.arctan2(dv[0],dv[1]))  # angle from mm +y axis
        d50=dir_at(50); d150=dir_at(R)
        # screen-coordinate crossing angle to compare with endPtAngle
        S=w2s(T[:,:2].astype(float)); rs=np.linalg.norm(S-start_s,axis=1); i=np.argmax(rs>=e.targetDist)
        if rs[i]>=e.targetDist and i>0:
            f=(e.targetDist-rs[i-1])/(rs[i]-rs[i-1]); q=S[i-1]+f*(S[i]-S[i-1]); ang=np.degrees(np.arctan2(-(q[1]-start_s[1]),q[0]-start_s[0]))
        else: ang=np.nan
        rows.append([stop,e.MTs[tr-1],pv,d50,d150,ang,e.endPtAngle[tr-1],np.median(np.diff(t))])
    return np.array(rows,float),R
KIN={}
for s in SUBJ:
    for task in ['sensorimotor','motoraware']:
        out=[]
        for tag,a,b in sources(s,task,A[s]['raw']):
            x=get(A[s]['raw'],tag); r,R=kin_trials(x,a,b); out.append(r)
        KIN[(s,task)]=np.vstack(out)
save(KIN,'kinematics.pkl')
K=np.vstack(list(KIN.values()))
print('R target mm', R)
print('nan rows',np.isnan(K[:,0]).sum(),'of',len(K))
print('sample interval median s', np.nanmedian(K[:,7]))
print('crossing angle vs endPtAngle: median abs diff %.3f deg, 95pct %.3f'%(np.nanmedian(abs(K[:,5]-K[:,6])),np.nanpercentile(abs(K[:,5]-K[:,6]),95)))
