"""Original floating MealMirror objects: 48px masters and light/dark 3x PNGs."""
from pathlib import Path
import os
import json
from PIL import Image, ImageDraw, ImageFont, ImageFilter

OUT = Path(os.environ.get('MEALMIRROR_ICON_OUT', str(Path(__file__).resolve().parent/'icons')))
OUT.mkdir(parents=True, exist_ok=True)

C = {
    'ink':'#2B2030', 'deep':'#171726', 'white':'#FFF8E8', 'cream':'#FFEFD1',
    'red':'#E84456', 'red_hi':'#FF7C75', 'red_lo':'#AF2A48',
    'orange':'#F78B40', 'orange_hi':'#FFBA52', 'orange_lo':'#BE4A39',
    'yellow':'#FFD45E', 'yellow_hi':'#FFEB93', 'yellow_lo':'#DA8F3C',
    'blue':'#397DCE', 'blue_hi':'#75C6F3', 'blue_lo':'#2E4D94',
    'mint':'#66CF9B', 'mint_hi':'#B5EFBC', 'mint_lo':'#248D75',
    'violet':'#AB79D6', 'violet_hi':'#D9A5E8', 'violet_lo':'#6D4D9A',
    'pink':'#F17EB2', 'pink_hi':'#FFC3D8', 'pink_lo':'#AD4C91',
    'slate':'#637593', 'slate_hi':'#B5CCDC', 'slate_lo':'#38455E',
}

def rgb(x): return C.get(x,x)

class Sprite:
    def __init__(self, palette):
        self.im = Image.new('RGBA',(48,48),(0,0,0,0))
        self.d = ImageDraw.Draw(self.im)
        # The object stands alone. Colour belongs to the object, not a square tile.
    def box(self, xy, c): self.d.rectangle(xy, fill=rgb(c))
    def poly(self, xy, c): self.d.polygon(xy, fill=rgb(c))
    def ellipse(self, xy, c): self.d.ellipse(xy, fill=rgb(c))
    def line(self, xy, c, w=1): self.d.line(xy, fill=rgb(c), width=w, joint='curve')
    def glint(self, x=12,y=12):
        self.box((x,y,x+3,y+1),'white')
        self.box((x,y+2,x+1,y+3),'white')
    def export(self, name):
        bounds=self.im.getchannel('A').getbbox()
        if not bounds: raise ValueError(name)
        art=self.im.crop(bounds)
        scale=min(40/art.width,40/art.height)
        size=(max(1,round(art.width*scale)),max(1,round(art.height*scale)))
        art=art.resize(size,Image.Resampling.NEAREST)
        master=Image.new('RGBA',(48,48),(0,0,0,0))
        master.alpha_composite(art,((48-size[0])//2,(48-size[1])//2))
        master.save(OUT/f'{name}-48.png')
        master.resize((144,144),Image.Resampling.NEAREST).save(OUT/f'{name}-144.png')
        alpha=master.getchannel('A').filter(ImageFilter.MaxFilter(3))
        dark=Image.new('RGBA',(48,48),'#FFF1DB')
        dark.putalpha(alpha)
        dark.alpha_composite(master)
        dark.resize((144,144),Image.Resampling.NEAREST).save(OUT/f'{name}-dark-144.png')
        return master

def camera(p='coral'):
    s=Sprite(p)
    s.box((11,17,36,35),'deep');s.box((13,19,34,32),'cream')
    s.box((11,21,36,32),'red_lo');s.box((13,22,34,30),'red')
    s.box((15,14,24,19),'deep');s.box((17,15,23,18),'slate_hi')
    s.box((29,18,33,20),'yellow_hi')
    s.ellipse((18,20,30,32),'deep');s.ellipse((20,22,28,30),'blue_hi')
    s.ellipse((22,23,26,27),'blue_lo');s.box((21,23,22,24),'white')
    s.box((14,22,15,26),'red_hi');s.box((13,32,33,33),'deep');s.glint(15,20)
    return s

def photos():
    s=Sprite('sky')
    s.box((11,12,30,31),'deep');s.box((13,14,28,28),'cream')
    s.box((16,17,37,36),'deep');s.box((18,19,35,33),'white')
    s.box((19,20,34,25),'blue_hi');s.box((19,26,34,32),'mint_hi')
    s.poly([(19,32),(25,25),(28,28),(31,25),(35,30),(35,33),(19,33)],'mint_lo')
    s.ellipse((29,21,33,25),'yellow');s.box((17,17,19,18),'white')
    s.box((18,34,34,35),'deep');return s

def label():
    s=Sprite('gold')
    s.box((14,10,33,37),'deep');s.box((16,12,31,34),'cream')
    s.box((17,13,30,18),'red');s.box((18,14,22,15),'red_hi')
    s.box((18,21,28,22),'ink');s.box((18,24,28,25),'slate')
    for x,w in [(18,1),(21,2),(25,1),(28,2)]:s.box((x,28,x+w,33),'ink')
    s.box((19,34,31,35),'deep');s.box((16,12,17,28),'white')
    return s

def plate():
    s=Sprite('orange')
    s.ellipse((9,14,38,40),'deep');s.ellipse((12,16,35,36),'white')
    s.ellipse((15,19,32,33),'slate_hi');s.ellipse((17,21,30,31),'cream')
    s.poly([(17,28),(20,21),(26,20),(31,24),(29,31),(22,33)],'orange_lo')
    s.box((21,24,27,28),'orange');s.box((21,22,24,23),'yellow_hi')
    s.ellipse((13,21,18,26),'mint_lo');s.box((15,20,17,23),'mint_hi')
    s.ellipse((28,19,34,25),'red_lo');s.box((30,20,33,22),'red_hi')
    s.glint(13,18);return s

def adjust():
    s=Sprite('violet')
    s.box((11,13,30,36),'deep');s.box((13,15,28,33),'cream')
    s.box((17,11,25,16),'deep');s.box((19,12,23,14),'slate_hi')
    s.box((16,20,26,21),'slate');s.box((16,24,23,25),'slate');s.box((16,28,21,29),'slate')
    s.poly([(28,20),(32,17),(38,23),(35,26),(22,37),(18,38),(19,33)],'deep')
    s.poly([(28,22),(32,19),(36,23),(33,26),(22,35),(20,36),(21,33)],'yellow')
    s.box((30,20,33,21),'yellow_hi');s.box((21,34,23,36),'pink_lo')
    return s

def history():
    s=Sprite('mint')
    s.ellipse((9,10,38,39),'deep');s.ellipse((12,13,35,36),'yellow')
    s.ellipse((15,16,32,33),'cream');s.box((22,18,24,25),'ink')
    s.box((23,24,30,26),'ink');s.box((22,23,25,27),'red')
    s.box((21,15,25,16),'white');s.box((32,23,34,25),'orange_lo')
    s.box((22,32,24,34),'orange_lo');s.glint(14,15);return s

def review():
    s=Sprite('sky')
    s.box((11,13,35,38),'deep');s.box((13,15,33,35),'cream')
    s.box((17,10,29,17),'deep');s.box((19,12,27,15),'blue_hi')
    s.poly([(16,26),(21,21),(27,20),(32,26),(27,31),(21,31)],'deep')
    s.poly([(18,26),(22,23),(27,22),(30,26),(26,29),(22,29)],'white')
    s.ellipse((22,23,27,28),'blue');s.ellipse((24,24,26,26),'deep')
    s.box((16,33,29,34),'slate');s.glint(14,17);return s

def save():
    s=Sprite('pink')
    s.box((10,13,37,37),'deep');s.box((12,15,35,34),'violet_lo')
    s.box((16,15,31,23),'cream');s.box((18,16,27,21),'blue_lo')
    s.box((15,27,32,34),'deep');s.box((18,28,29,33),'white')
    s.box((30,15,33,22),'ink');s.box((18,28,21,29),'slate_hi')
    s.box((12,15,14,31),'violet_hi');s.box((13,34,34,35),'deep')
    return s

def privacy():
    s=Sprite('slate')
    s.poly([(23,9),(37,14),(36,28),(31,35),(23,39),(15,35),(10,28),(9,14)],'deep')
    s.poly([(23,12),(34,16),(33,27),(29,33),(23,36),(17,33),(13,27),(12,16)],'blue')
    s.poly([(23,13),(31,16),(30,27),(24,33),(23,33)],'blue_hi')
    s.box((17,22,29,30),'deep');s.box((19,23,27,28),'yellow')
    s.box((19,18,27,24),'deep');s.box((21,19,25,23),'cream')
    s.box((22,25,24,27),'ink');s.box((14,16,16,23),'white');return s

def settings():
    s=Sprite('slate')
    # A regular machine gear: eight square teeth around a broad annular ring.
    # The old pointed outline could read as a blue star at header size.
    for bounds in ((20,5,28,17),(20,31,28,43),(5,20,17,28),(31,20,43,28),
                   (9,9,17,17),(31,9,39,17),(9,31,17,39),(31,31,39,39)):
        s.box(bounds,'deep')
    s.ellipse((11,11,37,37),'deep')
    for bounds in ((22,8,26,17),(22,31,26,40),(8,22,17,26),(31,22,40,26),
                   (12,12,17,17),(31,12,36,17),(12,31,17,36),(31,31,36,36)):
        s.box(bounds,'blue')
    s.ellipse((14,14,34,34),'blue')
    s.poly([(14,21),(17,15),(22,13),(28,14),(31,17),(26,18),(21,18),(18,23)],'blue_hi')
    s.ellipse((18,18,30,30),'deep')
    s.ellipse((21,21,27,27),'cream')
    s.box((21,21,23,22),'white')
    return s

def info():
    s=Sprite('sky')
    s.ellipse((11,10,37,38),'deep');s.ellipse((14,13,34,35),'cream')
    s.box((22,20,26,30),'blue_lo');s.box((21,20,25,22),'blue')
    s.box((21,28,27,30),'blue_lo');s.box((22,16,26,19),'red')
    s.box((15,16,17,19),'white');return s

def replay():
    s=Sprite('mint')
    s.d.arc((10,10,37,38),45,317,fill=rgb('deep'),width=9)
    s.d.arc((13,13,34,35),45,317,fill=rgb('mint'),width=4)
    s.poly([(37,9),(40,24),(26,18)],'deep')
    s.poly([(36,13),(37,20),(31,17)],'yellow_hi')
    s.box((12,20,14,24),'mint_hi')
    return s

def medical():
    s=Sprite('coral')
    s.box((11,17,36,35),'deep');s.box((13,19,34,32),'white')
    s.box((17,13,29,19),'deep');s.box((19,15,27,18),'cream')
    s.box((21,21,26,30),'red');s.box((18,24,29,27),'red')
    s.box((14,20,16,23),'slate_hi');s.box((14,32,33,34),'red_lo')
    return s

def details():
    s=Sprite('gold')
    s.box((12,11,32,36),'deep');s.box((14,13,30,33),'cream')
    for y,w in [(17,12),(21,10),(25,8)]:s.box((17,y,17+w,y+1),'slate')
    s.ellipse((24,23,37,36),'deep');s.ellipse((26,25,34,33),'blue_hi')
    s.box((30,27,32,30),'white');s.box((34,34,39,38),'deep')
    s.box((35,35,38,37),'blue_lo');return s

def delete():
    s=Sprite('coral')
    s.box((14,18,34,37),'deep');s.box((16,20,32,34),'cream')
    s.box((12,15,36,19),'deep');s.box((16,16,32,17),'red_hi')
    s.box((19,12,29,16),'deep');s.box((21,13,27,14),'cream')
    s.box((20,23,22,31),'red_lo');s.box((26,23,28,31),'red_lo')
    s.box((16,34,32,36),'deep');return s

def check():
    s=Sprite('mint')
    s.ellipse((11,10,37,38),'deep');s.ellipse((14,13,34,35),'cream')
    s.poly([(17,25),(20,22),(23,25),(30,17),(33,20),(23,31)],'deep')
    s.poly([(19,24),(21,23),(23,26),(30,19),(31,20),(23,29)],'mint_lo')
    s.box((15,15,18,16),'white');return s

def badge_plus(s, minus=False):
    s.box((28,28,42,42),'deep');s.box((30,30,40,40),'yellow')
    s.box((32,34,38,36),'deep')
    if not minus:s.box((34,32,36,38),'deep')
    s.box((30,30,33,31),'yellow_hi')

def add_photo():
    s=photos();badge_plus(s);return s

def remove_photo():
    s=photos();badge_plus(s,True);return s

def pending():
    s=review();s.box((28,30,41,42),'deep');s.box((30,32,39,40),'yellow')
    s.box((33,33,36,36),'ink');s.box((34,37,36,38),'ink')
    return s

def saved_record():
    s=review();s.box((28,30,41,42),'deep');s.box((30,32,39,40),'mint')
    s.poly([(31,36),(33,34),(35,36),(38,33),(40,35),(35,39)],'deep')
    return s

MAKERS = {
 'camera':camera,'photos':photos,'history':history,'info':info,'settings':settings,
 'check':check,'adjust':adjust,'review':review,'replay':replay,'privacy':privacy,
 'medical':medical,'details':details,'delete':delete,'save':save,'foodView':plate,
 'nutritionLabel':label,'addPhoto':add_photo,'removePhoto':remove_photo,
 'reviewPendingRecord':pending,'reviewSavedRecord':saved_record,
}

NAMES = {
 'camera':'Camera','photos':'Library','history':'Local history','info':'How it works',
 'settings':'Settings','check':'Confirmed choice','adjust':'Adjust ingredients',
 'review':'Review details','replay':'Start another','privacy':'Privacy',
 'medical':'Medical safety','details':'View details','delete':'Delete review',
 'save':'Save review','foodView':'Food view','nutritionLabel':'Nutrition label',
 'addPhoto':'Add photo','removePhoto':'Remove photo','reviewPendingRecord':'Not saved',
 'reviewSavedRecord':'Saved locally',
}

def main():
    icons={k: maker().export(k) for k,maker in MAKERS.items()}
    try:
        font=ImageFont.truetype(str(Path(__file__).resolve().parents[2]/'MealMirror.swiftpm/Fonts/Nunito.ttf'),22)
        head=ImageFont.truetype(str(Path(__file__).resolve().parents[2]/'MealMirror.swiftpm/Fonts/PixelifySans.ttf'),44)
    except OSError: font=ImageFont.load_default();head=font
    for dark in (False,True):
        atlas=Image.new('RGB',(1200,1220),'#211B27' if dark else '#FFF6D8');d=ImageDraw.Draw(atlas)
        ink='#FFF1DB' if dark else '#32202C'
        muted='#DBC9D1' if dark else '#6A4C50'
        d.text((42,24),'PIXEL KITCHEN / ICON FAMILY',font=head,fill=ink)
        d.text((44,83),'Original objects  •  no icon backplates  •  visible labels',font=font,fill=muted)
        for row in range(1,4):
            y=136+row*260
            d.line((42,y,1158,y),fill='#6F5868' if dark else '#D4B8A7',width=2)
        for i,(k,im) in enumerate(icons.items()):
            x=42+(i%5)*232;y=144+(i//5)*260
            if dark:im=Image.open(OUT/f'{k}-dark-144.png')
            else:im=im.resize((144,144),Image.Resampling.NEAREST)
            atlas.paste(im,(x+35,y+19),im)
            d.text((x+13,y+184),NAMES[k],font=font,fill=ink)
        atlas.save(OUT.parent/('pixel-kitchen-icon-atlas-dark.png' if dark else 'pixel-kitchen-icon-atlas.png'))
    semantics={k:{'label':NAMES[k],'asset':f'{k}-144.png','master':f'{k}-48.png','role':'status' if k in ('foodView','nutritionLabel','reviewPendingRecord','reviewSavedRecord') else 'action','visible_text_required':True} for k in icons}
    (OUT/'icon-map.json').write_text(json.dumps(semantics,indent=2)+'\n')
    print(len(icons), 'icons at',OUT)

if __name__=='__main__':main()
