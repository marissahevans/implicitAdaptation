"""Shows that the processed report variable has the opposite sign to the on-screen report position for most
files, and that the on-screen position reproduces which trials earned points."""
import sys, os; sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from common import *
import pickle
A = data()
def _unused_geo_report(e,a,b):
    """report direction from the on-screen position of the report dot, same frame as endPtAngle-90 (positive = left)"""
    arc=np.asarray(e.reportArc,float); stp=np.asarray(e.startPos,float); ra=np.asarray(e.reportAngle,float)
    if arc.ndim==2 and len(arc)>=b:
        ang=np.degrees(np.arctan2(-(arc[a:b,1]-stp[1]),arc[a:b,0]-stp[0]))-90
        bad=np.abs(ang)>60   # unset rows
        if bad.any(): ang[bad]=np.nan
        return ang
    return None
def _unused_task_geo(s,t):
    raws=A[s]['raw']; segs=sources(s,t,raws); rep=[];reach=[];clamp=[];conf=[];pts=[];start=[];ctime=[]
    for tag,a,b in segs:
        e=get(raws,tag)['e']; rep.append(geo_report(e,a-1,b) if t=='motoraware' else np.full(b-a+1,np.nan))
        reach.append(np.asarray(e.endPtAngle,float)[a-1:b]-90); clamp.append(np.asarray(e.errorClamp,float)[a-1:b]-90)
        conf.append(np.asarray(e.confAngle,float)[a-1:b]); pts.append(np.asarray(e.pointsEarned,float)[a-1:b])
        start.append(np.asarray(e.arcStart,float)[a-1:b]); ctime.append(np.asarray(e.confTime,float)[a-1:b])
    c=np.concatenate
    return dict(report_raw=c(rep),reach_raw=c(reach),clamp=c(clamp),conf=c(conf),points=c(pts),arcstart=c(start),conftime=c(ctime))
if __name__=='__main__':
    print('participant: proc-report vs geo-report corr | hit agreement using geo error (|e|<=w/2) | using proc-sign error')
    for i,s in enumerate(SUBJ):
        g=task_geo(s,'motoraware'); P=A[s]['motoraware']
        geo=g['report_raw']; ok=np.isfinite(geo)
        r=np.corrcoef(P['report'][ok],geo[ok])[0,1]
        hit=g['points']>0; w=g['conf']
        ag=np.mean((np.abs(geo-g['reach_raw'])<=w/2)[ok]==hit[ok])
        ra=np.concatenate([np.asarray(get(A[s]['raw'],tag)['e'].reportAngle,float)[a-1:b] for tag,a,b in sources(s,'motoraware',A[s]['raw'])])
        ag2=np.mean((np.abs(ra-g['reach_raw'])<=w/2)==hit)
        print('P%-2d %s corr(proc,geo)=%+.2f  nan=%d  hit-agree geo=%.3f  reportAngle-as-is=%.3f'%(i+1,s,r,(~ok).sum(),ag,ag2))
