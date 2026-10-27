"""Original 24-pixel silhouettes for the smallest MealMirror content roles."""
from pathlib import Path
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT=Path(os.environ.get('MEALMIRROR_COMPACT_ROOT', str(Path(__file__).resolve().parent)))
OUT=ROOT/'icons'/'compact'
OUT.mkdir(parents=True,exist_ok=True)
C={'line':'#171726','paper':'#FFF4DA','white':'#FFFDF1','red':'#E84456','redHi':'#FF8C75',
   'blue':'#397DCE','blueHi':'#75C6F3','mint':'#49B788','mintHi':'#B5EFBC',
   'gold':'#FFD45E','goldHi':'#FFEB93','slate':'#647592'}

def sprite():
    im=Image.new('RGBA',(24,24));return im,ImageDraw.Draw(im)
def box(d,xy,c):d.rectangle(xy,fill=C[c])
def circle(d,xy,c):d.ellipse(xy,fill=C[c])
def poly(d,xy,c):d.polygon(xy,fill=C[c])

def camera():
    im,d=sprite();box(d,(2,7,21,19),'line');box(d,(4,9,19,17),'red');box(d,(5,5,11,8),'line');box(d,(6,6,10,8),'blueHi')
    circle(d,(8,9,16,17),'line');circle(d,(10,11,14,15),'blueHi');box(d,(11,11,12,12),'white');box(d,(17,10,18,11),'gold')
    return im
def photos():
    im,d=sprite();box(d,(2,4,17,17),'line');box(d,(4,6,15,14),'blue');box(d,(6,12,11,14),'mint')
    box(d,(7,8,22,21),'line');box(d,(9,10,20,19),'blueHi');circle(d,(16,11,18,13),'gold');poly(d,[(9,18),(13,13),(16,16),(18,14),(20,18)],'mint')
    return im
def foodView():
    im,d=sprite();circle(d,(2,2,21,21),'line');circle(d,(4,4,19,19),'paper');circle(d,(6,6,17,17),'white')
    circle(d,(8,9,14,15),'red');box(d,(9,9,11,10),'redHi');poly(d,[(13,8),(17,6),(15,11)],'mint');box(d,(6,15,17,16),'gold')
    return im
def nutritionLabel():
    im,d=sprite();box(d,(4,2,19,21),'line');box(d,(6,4,17,19),'paper');box(d,(7,5,16,7),'red')
    box(d,(7,9,16,10),'line');box(d,(7,12,14,13),'line');box(d,(7,15,12,16),'slate')
    for x in (14,16):box(d,(x,15,x,18),'line')
    return im
def record(saved):
    im,d=sprite();box(d,(4,2,17,21),'line');box(d,(6,4,15,19),'paper');box(d,(8,2,13,5),'line');box(d,(9,3,12,4),'blueHi')
    box(d,(8,8,13,9),'slate');box(d,(8,11,12,12),'slate');circle(d,(13,12,22,21),'line');circle(d,(15,14,20,19),'mint' if saved else 'gold')
    if saved:poly(d,[(15,17),(16,16),(17,17),(19,15),(20,16),(17,19)],'line')
    else:box(d,(17,15,18,17),'line');box(d,(17,19,18,19),'line')
    return im

MAKERS={'camera':camera,'photos':photos,'foodView':foodView,'nutritionLabel':nutritionLabel,
        'reviewPendingRecord':lambda:record(False),'reviewSavedRecord':lambda:record(True)}
LABELS={'camera':'Camera','photos':'Library','foodView':'Food view','nutritionLabel':'Nutrition label',
        'reviewPendingRecord':'Not saved','reviewSavedRecord':'Saved locally'}
images={}
for name,make in MAKERS.items():
    im=make();im.save(OUT/f'{name}-24.png');im.resize((72,72),Image.Resampling.NEAREST).save(OUT/f'{name}-72.png')
    alpha=im.getchannel('A').filter(ImageFilter.MaxFilter(3));edge=Image.new('RGBA',im.size,'#FFF1DB');edge.putalpha(alpha);edge.alpha_composite(im)
    edge.resize((72,72),Image.Resampling.NEAREST).save(OUT/f'{name}-dark-72.png');images[name]=(im,edge)

try:font=ImageFont.truetype(str(Path(__file__).resolve().parents[2]/'MealMirror.swiftpm/Fonts/Nunito.ttf'),17)
except OSError:font=ImageFont.load_default()
sheet=Image.new('RGB',(960,570),'#FFF6D8');d=ImageDraw.Draw(sheet)
d.text((25,15),'COMPACT OBJECTS / ACTUAL 24px AND 3× PREVIEW',font=font,fill='#32202C')
for idx,(name,(light,dark)) in enumerate(images.items()):
    x=25+(idx%3)*310;y=60+(idx//3)*245
    d.rounded_rectangle((x,y,x+290,y+218),radius=12,fill='#FFFCF1',outline='#4B2A35',width=2)
    d.text((x+15,y+11),LABELS[name],font=font,fill='#32202C')
    sheet.paste(light,(x+24,y+60),light)
    enlarged=light.resize((72,72),Image.Resampling.NEAREST);sheet.paste(enlarged,(x+95,y+43),enlarged)
    d.rounded_rectangle((x+188,y+49,x+274,y+135),radius=8,fill='#211B27')
    sheet.paste(dark,(x+219,y+80),dark)
    d.text((x+18,y+158),'24px',font=font,fill='#6A4C50');d.text((x+92,y+158),'72px export',font=font,fill='#6A4C50')
    d.text((x+190,y+158),'dark 24px',font=font,fill='#6A4C50')
sheet.save(ROOT/'pixel-kitchen-compact-actual-size.png')
print('Six separate compact icons:',OUT)
