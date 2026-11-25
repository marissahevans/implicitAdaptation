"""Checks that the processed per-task files match the raw session files trial by trial."""
import sys, os; sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import numpy as np
sys.path.insert(0,'.')
from common import *
A = data()
for s,r in A.items():
    for task in ['sensorimotor','motoraware']:
        segs=sources(s,task,r['raw'])
        ep=np.concatenate([get(r['raw'],t)['e'].endPtAngle[a-1:b]-90 for t,a,b in segs])
        cl=np.concatenate([get(r['raw'],t)['e'].errorClamp[a-1:b]-90 for t,a,b in segs])
        cf=np.concatenate([get(r['raw'],t)['e'].confAngle[a-1:b] for t,a,b in segs])
        P=r[task]
        d=[np.max(abs((ep-ep.mean())-P['endPt'])), np.max(abs(cl-P['errClamp'])), np.max(abs(cf-P['confRep']))]
        if task=='motoraware':
            rp=np.concatenate([-get(r['raw'],t)['e'].reportAngle[a-1:b] for t,a,b in segs]); d.append(np.max(abs((rp-rp.mean())-P['report'])))
        if max(d)>1e-6: print('MISMATCH',s,task,d)
print('done')
