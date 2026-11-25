"""Supplemental Tables S1-S3 as CSV files in results/."""
from common import *
import pickle
import csv
R=load('fourier.pkl'); R2=load('cues.pkl')
def g(t,k): return np.array([R[(s,t)][k] for s in SUBJ])
import os
from config import RESULTS
O=RESULTS+os.sep
def fp(p): return '<.0001' if p<1e-4 else ('%.4f'%p if p<.01 else '%.3f'%p)
t='sensorimotor'; q=bh(g(t,'conf_p')); rq=bh(g(t,'rect_p'))
rows=[['P','Reach amp','Reach lag','Conf amp','Conf lag','Conf p','Conf q','Conf SNR','Rect. q']]
for i in range(20):
    rows.append([str(i+1),'%.1f'%g(t,'reach_amp')[i],'%.1f'%g(t,'reach_lag')[i],'%.2f'%g(t,'conf_amp')[i],'%.1f'%g(t,'conf_lag')[i],fp(g(t,'conf_p')[i]),fp(q[i]),'%.1f'%g(t,'conf_snr')[i],fp(rq[i])])
csv.writer(open(O+'TableS1a.csv','w')).writerows(rows)
t='motoraware'; q=bh(g(t,'conf_p')); rq=bh(g(t,'rect_p')); qr=bh(g(t,'rep_p'))
rows=[['P','Reach amp','Report amp','Report lag','Report q','Conf amp','Conf lag','Conf q','Conf SNR','Rect. q']]
for i in range(20):
    L=g(t,'rep_lag')[i]; L=L-20 if L>15 else L
    rows.append([str(i+1),'%.1f'%g(t,'reach_amp')[i],'%.1f'%g(t,'rep_amp')[i],'%.1f'%L,fp(qr[i]),'%.2f'%g(t,'conf_amp')[i],'%.1f'%g(t,'conf_lag')[i],fp(q[i]),'%.1f'%g(t,'conf_snr')[i],fp(rq[i])])
csv.writer(open(O+'TableS1b.csv','w')).writerows(rows)
rows=[['P','SM best model','SM ΔAIC','MA best model','MA ΔAIC']]
sg={t:bh(g(t,'conf_p'))<.01 for t in ['sensorimotor','motoraware']}
for i in range(20):
    a=R2['sensorimotor']['best'][i]; b=R2['motoraware']['best'][i]
    rows.append([str(i+1),' + '.join(a[0])+(' *' if sg['sensorimotor'][i] else ''),'%.1f'%a[1],' + '.join(b[0])+(' *' if sg['motoraware'][i] else ''),'%.1f'%b[1]])
csv.writer(open(O+'TableS2.csv','w')).writerows(rows)
AD=load('additional.pkl'); RP=AD['report']; SS=AD['ss']; PB=AD['points']
rows=[['P','Report group','Hand wt','Cursor wt','Loc. k','SM A','SM B','MA A','MA B','SM pts (actual/best)','MA pts (actual/best)']]
for i in range(20):
    rows.append([str(i+1),RP['grp'][i],'%.2f'%RP['WH'][i,0],'%.2f'%RP['WC'][i,0],'%.2f'%RP['K'][i],
                 '%.2f'%SS['sensorimotor'][i,0],'%.2f'%SS['sensorimotor'][i,1],'%.2f'%SS['motoraware'][i,0],'%.2f'%SS['motoraware'][i,1],
                 '%.0f/%.0f'%(PB['sensorimotor'][i,0],PB['sensorimotor'][i,2]),'%.0f/%.0f'%(PB['motoraware'][i,0],PB['motoraware'][i,2])])
csv.writer(open(O+'TableS3.csv','w')).writerows(rows)
for f in ['TableS1a','TableS1b','TableS2','TableS3']: print(f+'.csv written')
