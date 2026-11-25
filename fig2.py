"""Fig. 2 (predicted responses over one clamp cycle). Starts from the authors' original schematic SVGs in
assets/fig2, redraws the confidence predictions as rectified sinusoids and updates the labels, then renders
the two halves and stacks them."""
import os, re, subprocess, numpy as np
from config import ASSETS, RESULTS, FIGURES
D=os.path.join(ASSETS,'fig2')+os.sep
W_=os.path.join(RESULTS,'fig2_work')+os.sep; os.makedirs(W_,exist_ok=True)
def rect_points(x0,step,y0conf,lo,hi,lag,start_t=1,end_t=20):
    # confidence (deg) = lo + (hi-lo)*|sin(2π(t-1-lag)/20)| ; y = y0conf - conf*12.28
    t=np.arange(start_t,end_t+1e-9,0.05)
    c=lo+(hi-lo)*np.abs(np.sin(2*np.pi*(t-1-lag)/20))
    x=x0+(t-1)*step; y=y0conf-c*12.28
    return ' '.join('%.1f %.1f'%(a,b) for a,b in zip(x,y))
def conf_range(points,y0conf):
    ys=np.array([float(v) for v in points.split()][1::2]); c=(y0conf-ys)/12.28; return c.min(),c.max()
# ---- SM: confidence curves as rectified sinusoids
s=open(D+'SM_sample_waves.svg').read()
pat=r'(<polyline class="cls-18" points=")([^"]+)(")'
m=re.search(pat,s); lo,hi=conf_range(m.group(2),328.9); print('SM solid conf range',lo,hi)
s=s.replace(m.group(0),m.group(1)+rect_points(475.2,(758-475.2)/19,328.9,lo,hi,0)+m.group(3))
pat=r'(<polyline class="cls-15" points=")([^"]+)(")'
m=re.search(pat,s); lo2,hi2=conf_range(m.group(2),328.9); print('SM dotted',lo2,hi2)
s=s.replace(m.group(0),m.group(1)+rect_points(475.2,(758-475.2)/19,328.9,lo,hi,1.0,start_t=2)+m.group(3))
s=s.replace('font-family: Helvetica, Helvetica;','font-family: Helvetica, Arial, "Liberation Sans", sans-serif;')
open(W_+'SM_rect.svg','w').write(s)
# ---- MA
s=open(D+'MA_sample_waves.svg').read()
pat=r'(<polyline class="cls-12" points=")([^"]+)(")'
m=re.search(pat,s); lo,hi=conf_range(m.group(2),328.9); print('MA solid',lo,hi)
s=s.replace(m.group(0),m.group(1)+rect_points(481.3,(764-481.3)/19,328.9,lo,hi,0)+m.group(3))
pat=r'(<polyline class="cls-2" points=")([^"]+)(")'
m=re.search(pat,s); print('MA dotted',conf_range(m.group(2),328.9))
s=s.replace(m.group(0),m.group(1)+rect_points(481.3,(764-481.3)/19,328.9,lo,hi,1.0,start_t=1.5,end_t=19.7)+m.group(3))
s=s.replace('font-family: Helvetica, Helvetica;','font-family: Helvetica, Arial, "Liberation Sans", sans-serif;')
s=s.replace('<tspan x="0" y="0">A</tspan>','<tspan x="0" y="0">C</tspan>').replace('<tspan x="0" y="0">B</tspan>','<tspan x="0" y="0">D</tspan>')
open(W_+'MA_rect.svg','w').write(s)

def txt(cls,x,y,lines,extra=''):
    return f'<text class="{cls}" transform="translate({x} {y})"{extra}>'+''.join(f'<tspan x="0" y="{21.6*i:.1f}">{l}</tspan>' for i,l in enumerate(lines))+'</text>'
def rep_text(s,first,new):
    m=re.search(r'<text[^>]*>(?:(?!</text>).)*?'+re.escape(first)+r'.*?</text>',s,re.S); assert m,first
    return s.replace(m.group(0),new)
def shift_poly(s,startpts,dx=0,dy=0):
    m=re.search(r'(<polygon class="[^"]+" points=")('+re.escape(startpts)+r'[^"]*)(")',s); assert m,startpts
    v=np.array([float(a) for a in m.group(2).split()]).reshape(-1,2)+[dx,dy]
    return s.replace(m.group(0),m.group(1)+' '.join('%.1f %.1f'%tuple(p) for p in v)+m.group(3))
def titles(s,items,dy=34):
    vb=re.search(r'viewBox="([^"]+)"',s).group(1).split(); x0,y0,w,h=map(float,vb)
    s=s.replace(re.search(r'viewBox="[^"]+"',s).group(0),f'viewBox="{x0} {y0-dy} {w} {h+dy}"')
    add=''.join(f'<text transform="translate({x} {-dy/2+6})" style="font-family: Helvetica, Arial, \'Liberation Sans\', sans-serif; font-size: 19px; font-weight: bold; fill:#212121">{t}</text>' for x,t in items)
    add=f'<rect x="{x0}" y="{y0-dy}" width="{w}" height="{dy+1}" fill="#fff"/>'+add
    return s.replace('</svg>',add+'</svg>')
def arrow(cx, tip, tail):
    """vertical block arrow in the original style; points down if tip > tail"""
    d = 1 if tip > tail else -1
    hb = tip - d*23.2; nb = tip - d*20.4
    pts = [(cx+3.15, tail), (cx+3.15, hb), (cx+9.8, nb), (cx, tip), (cx-9.8, nb), (cx-3.15, hb), (cx-3.15, tail), (cx+3.15, tail)]
    return ' '.join('%.1f %.1f' % p for p in pts)
# ---------- SM (A,B)
s=open(W_+'SM_rect.svg').read()
m=re.search(r'<polyline class="cls-18" points="([^"]+)"',s); ys=np.array([float(v) for v in m.group(1).split()][1::2]); c=(328.9-ys)/12.28; lo,hi=c.min(),c.max()
m=re.search(r'(<polyline class="cls-15" points=")([^"]+)(")',s)
s=s.replace(m.group(0),m.group(1)+rect_points(475.2,(758-475.2)/19,328.9,lo,hi,1.9,start_t=1)+m.group(3))
s=rep_text(s,'No lag, most',txt('cls-2',481.7,40.9,['No lag: least','confident when the','clamp is farthest','from the target'],' style="font-size:16px"'))
s=rep_text(s,'Trial lag, most',txt('cls-2',600,411.4,['~2-trial lag: most','confident (narrowest','arc) when the hand','is nearest the target']))
s=shift_poly(s,'636.9 387.1',dx=12.5)
s=s.replace('Implictly adapted','Implicitly adapted')
s=titles(s,[(77.7,'Reach (both tasks)'),(475.2,'Sensorimotor task: confidence')])
open(W_+'Fig02_AB.svg','w').write(s)
# ---------- MA (C,D)
s=open(W_+'MA_rect.svg').read()
# C: intermediate report = hand and clamp pulls nearly cancel -> small amplitude, leads clamp by ~4 trials
t=np.arange(1,20.001,0.25); y=2.0*np.sin(2*np.pi*(t-1+4)/20); x=83.8+(t-1)*(365.8-83.8)/19; py=255.3-y*12.28
m=re.search(r'(<polyline class="cls-15" points=")([^"]+)(")',s); s=s.replace(m.group(0),m.group(1)+' '.join('%.1f %.1f'%(a,b) for a,b in zip(x,py))+m.group(3))
m=re.search(r'(<polyline class="cls-8" points=")([^"]+)(")',s); s=s.replace(m.group(0),m.group(1)+' '.join('%.1f %.1f'%(a+397.5,b) for a,b in zip(x,py))+m.group(3))
# arrow for blend: point to trough of intermediate curve near trial 12 (x≈247.6, y≈279.9), from above
m=re.search(r'(<polygon class="cls-27" points=")(201.4 122.6[^"]*)(")',s)
s=s.replace(m.group(0), m.group(1)+arrow(110, 228, 116)+m.group(3))
m=re.search(r'(<polygon class="cls-27" points=")(656.9 346.5[^"]*)(")',s)
s=s.replace(m.group(0), m.group(1)+arrow(660.1, 268, 392)+m.group(3))
s=rep_text(s,'Blend of hand and',txt('cls-25',88,42,['Hand and clamp pull','about equally and','largely cancel: small,','intermediate lag'],' style="font-size:16px"'))
s=rep_text(s,'error clamp position','')
s=rep_text(s,'Anti-phase from',txt('cls-25',96,378,['Follows the hand','(anti-phase)']))
s=s.replace('<text class="cls-25" transform="translate(100.5 399.6)"><tspan x="0" y="0">error clamp</tspan></text>','')
s=rep_text(s,'No lag, most',txt('cls-25',486.8,46.6,['No lag: least','confident when the','clamp is farthest','from the target'],' style="font-size:16px"'))
for w in ['confident when ','error clamp and ','motor plan align']:
    s=rep_text(s,'>'+w+'<','')
s=rep_text(s,'Trial lag, most',txt('cls-25',562.7,412,['~1-trial lag: most','confident when the','clamp–hand mismatch','is smallest']))
for w in ['hand and<','error clamp align']:
    s=rep_text(s,w,'')
s=re.sub(r'<text class="cls-25" transform="translate\(562.7 386.5\)"><tspan x="0" y="0">confident when </tspan></text>','',s)
s=titles(s,[(83.8,'Motor-awareness task: report'),(481.3,'Motor-awareness task: confidence')])
open(W_+'Fig02_CD.svg','w').write(s)

# ---------- render and stack (needs rsvg-convert from librsvg)
from PIL import Image
pngs=[]
for nm in ['Fig02_AB','Fig02_CD']:
    subprocess.run(['rsvg-convert','-b','white','-z','2',W_+nm+'.svg','-o',W_+nm+'.png'],check=True); pngs.append(Image.open(W_+nm+'.png').convert('RGB'))
w=max(p.width for p in pngs); im=Image.new('RGB',(w,sum(p.height for p in pngs)),'white'); y=0
for p in pngs: im.paste(p,(0,y)); y+=p.height
im.save(os.path.join(FIGURES,'Fig02_predictions.png'),dpi=(300,300)); print('Fig02_predictions.png',im.size)
