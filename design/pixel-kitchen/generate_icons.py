"""Original MealMirror pixel icon studies. 48px master, nearest-neighbour exports."""
from pathlib import Path
import os
import json
from PIL import Image, ImageDraw, ImageFont

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

PALETTES = {
    'coral':('red_hi','red','red_lo'),
    'sky':('blue_hi','blue','blue_lo'),
    'gold':('yellow_hi','yellow','orange_lo'),
    'mint':('mint_hi','mint','mint_lo'),
    'violet':('violet_hi','violet','violet_lo'),
    'pink':('pink_hi','pink','pink_lo'),
    'orange':('orange_hi','orange','orange_lo'),
    'slate':('slate_hi','slate','slate_lo'),
}

def rgb(x): return C.get(x,x)

class Sprite:
    def __init__(self, palette):
        self.im = Image.new('RGBA',(48,48),(0,0,0,0))
        self.d = ImageDraw.Draw(self.im)
        self.tile(palette)
    def box(self, xy, c): self.d.rectangle(xy, fill=rgb(c))
    def poly(self, xy, c): self.d.polygon(xy, fill=rgb(c))
    def ellipse(self, xy, c): self.d.ellipse(xy, fill=rgb(c))
    def line(self, xy, c, w=1): self.d.line(xy, fill=rgb(c), width=w, joint='curve')
    def tile(self, palette):
        hi, mid, lo = PALETTES[palette]
        # Square, stepped rim and a deliberate lower-right hard shadow.
        self.poly([(5,3),(42,3),(42,5),(45,5),(45,40),(43,40),(43,44),(6,44),(6,42),(3,42),(3,6),(5,6)],'deep')
        self.poly([(6,6),(41,6),(41,8),(43,8),(43,39),(41,39),(41,41),(7,41),(7,39),(5,39),(5,8),(6,8)],mid)
        self.box((7,7,40,11),hi)
        self.box((7,12,40,34),mid)
        self.box((7,35,40,39),lo)
        self.box((8,8,25,9),'white')
        self.box((8,10,10,15),hi)
        self.box((37,14,39,32),lo)
        self.box((11,41,39,43),'deep')
        self.box((43,11,45,38),'deep')
        self.box((8,39,12,40),hi)
    def glint(self, x=12,y=12):
        self.box((x,y,x+3,y+1),'white')
        self.box((x,y+2,x+1,y+3),'white')
    def export(self, name):
        self.im.save(OUT/f'{name}-48.png')
        self.im.resize((144,144),Image.Resampling.NEAREST).save(OUT/f'{name}-144.png')
        return self.im

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
    s.box((23,24,29,26),'ink');s.box((21,23,25,27),'red')
    s.box((21,15,25,16),'white');s.box((32,23,34,25),'orange_lo')
    s.box((22,32,24,34),'orange_lo');s.glint(14,15);return s

def review():
    s=Sprite('sky')
    s.box((10,12,30,36),'deep');s.box((12,14,28,33),'cream')
    s.box((14,17,25,18),'slate');s.box((14,21,23,22),'slate');s.box((14,25,21,26),'slate')
    s.ellipse((23,22,38,37),'deep');s.ellipse((25,24,35,34),'blue_hi')
    s.ellipse((28,27,32,31),'white');s.line([(36,35),(40,39)],'deep',4)
    s.line([(36,35),(39,38)],'yellow',2);s.glint(13,15);return s

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
    s=Sprite('violet')
    for xy in [(21,10,27,37),(10,21,37,27),(14,14,33,33)]:s.box(xy,'deep')
    s.ellipse((13,13,34,34),'deep');s.ellipse((16,16,31,31),'slate_hi')
    s.ellipse((20,20,27,27),'deep');s.ellipse((22,22,25,25),'yellow')
    s.box((17,16,20,17),'white');s.box((14,23,15,26),'violet_hi')
    return s

def info():
    s=Sprite('sky')
    s.ellipse((11,10,37,38),'deep');s.ellipse((14,13,34,35),'cream')
    s.box((22,20,26,30),'blue_lo');s.box((21,20,25,22),'blue')
    s.box((21,28,27,30),'blue_lo');s.box((22,16,26,19),'red')
    s.box((15,16,17,19),'white');return s

def replay():
    s=Sprite('mint')
    s.ellipse((12,13,36,37),'deep');s.ellipse((16,17,32,33),'mint')
    s.box((18,14,29,17),'cream');s.box((31,19,34,28),'cream')
    s.box((20,33,29,36),'yellow');s.box((13,22,16,29),'yellow')
    s.poly([(10,17),(21,11),(20,23)],'deep')
    s.poly([(13,17),(19,14),(19,20)],'yellow_hi')
    s.box((30,31,32,33),'cream');return s

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
    atlas=Image.new('RGB',(1200,1220),'#221B29');d=ImageDraw.Draw(atlas)
    try:
        font=ImageFont.truetype(str(Path(__file__).resolve().parents[2]/'MealMirror.swiftpm/Fonts/Nunito.ttf'),22)
        head=ImageFont.truetype(str(Path(__file__).resolve().parents[2]/'MealMirror.swiftpm/Fonts/PixelifySans.ttf'),44)
    except OSError: font=ImageFont.load_default();head=font
    d.text((42,24),'PIXEL KITCHEN / ICON FAMILY',font=head,fill='#FFF1DB')
    d.text((44,83),'Original MealMirror concepts  •  48-pixel masters  •  source labels remain essential',font=font,fill='#CDBFD1')
    for i,(k,im) in enumerate(icons.items()):
        x=42+(i%5)*232;y=144+(i//5)*260
        d.rounded_rectangle((x,y,x+215,y+238),radius=12,fill='#FFF7E2')
        d.rounded_rectangle((x+2,y+2,x+213,y+236),radius=11,outline='#846675',width=2)
        atlas.paste(im.resize((156,156),Image.Resampling.NEAREST),(x+30,y+16),im.resize((156,156),Image.Resampling.NEAREST))
        d.text((x+14,y+187),NAMES[k],font=font,fill='#32202C')
    atlas.save(OUT.parent/'pixel-kitchen-icon-atlas.png')
    semantics={k:{'label':NAMES[k],'asset':f'{k}-144.png','master':f'{k}-48.png','role':'status' if k in ('foodView','nutritionLabel','reviewPendingRecord','reviewSavedRecord') else 'action','visible_text_required':True} for k in icons}
    (OUT/'icon-map.json').write_text(json.dumps(semantics,indent=2)+'\n')
    print(len(icons), 'icons at',OUT)

if __name__=='__main__':main()
