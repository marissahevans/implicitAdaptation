"""Paths used by every script. Set IAC_DATA to the folder that holds one sub-folder per participant
(e.g. data/AS/AS_errClamp_exp_S1_..._errresults.mat), or put that folder at ./data."""
import os
ROOT = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.environ.get('IAC_DATA', os.path.join(ROOT, 'data'))
RESULTS = os.path.join(ROOT, 'results')
FIGURES = os.path.join(ROOT, 'figures')
ASSETS = os.path.join(ROOT, 'assets')
for _d in (RESULTS, FIGURES): os.makedirs(_d, exist_ok=True)
def res(name): return os.path.join(RESULTS, name)
