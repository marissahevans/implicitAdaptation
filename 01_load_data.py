"""Read every participant's .mat files (raw per-session errresults/dispInfo files and the processed
per-task files) into results/all.pkl."""
import scipy.io as sio, glob, numpy as np, os, pickle, re
from config import DATA_DIR, res
from common import SUBJ
out = {}
for s in SUBJ:
    p = os.path.join(DATA_DIR, s); r = {}
    for task in ['sensorimotor', 'motoraware']:
        m = sio.loadmat(f'{p}/{s}_{task}.mat', squeeze_me=True); r[task] = {k: v for k, v in m.items() if not k.startswith('__')}
    for nm in ['sigmaFit', 'confPermute', 'reportPermute']:
        m = sio.loadmat(f'{p}/{s}_{nm}.mat', squeeze_me=True); r[nm] = {k: v for k, v in m.items() if not k.startswith('__')}
    raws = []
    for f in sorted(glob.glob(f'{p}/*errresults.mat')):
        e = sio.loadmat(f, squeeze_me=True, struct_as_record=False)['errResultsMat']
        fd = f.replace('errresults', 'dispInfo')
        di = sio.loadmat(fd, squeeze_me=True, struct_as_record=False)['displayInfo'] if os.path.exists(fd) else None
        raws.append(dict(file=os.path.basename(f), sess=int(re.search(r'_S(\d)_', f).group(1)), e=e, d=di))
    r['raw'] = raws; out[s] = r
    print(s, 'files:', len(raws))
pickle.dump(out, open(res('all.pkl'), 'wb'))
