# 拼音（字典讀音格式）→ bopomofo_t9 鍵序 轉換器
# 忠實重現 schema speller/algebra 的轉換順序（無聲調輸入）
import re

def syl_to_keys(syl):
    s = re.sub(r'[1-5]$', '', syl)
    s = s.replace('q', 'A').replace('x', 'B')
    for a, b in [('yong','vP'),('iong','vP'),('weng','uP'),('ong','uP'),('ing','iP')]:
        s = s.replace(a, b)
    s = re.sub(r'^yu', 'v', s)
    s = re.sub(r'^yi?', 'i', s)
    s = re.sub(r'^wu?', 'u', s)
    s = s.replace('iu', 'iou').replace('ui', 'uei')
    s = re.sub(r'^([jAB])u', r'\1v', s)
    s = re.sub(r'([iuv])n', r'\1en', s)
    s = re.sub(r'^zhi?', 'Z', s)
    s = re.sub(r'^chi?', 'C', s)
    s = re.sub(r'^shi?', 'S', s)
    s = re.sub(r'^([zcsr])i', r'\1', s)
    for a, b in [('ai','I'),('ei','J'),('ao','K'),('ou','L'),('ang','O'),
                 ('eng','P'),('an','M'),('en','N'),('er','R'),('eh','E')]:
        s = s.replace(a, b)
    s = re.sub(r'([iv])e', r'\1E', s)
    digit = {
        'b':'1','d':'1','a':'1',
        'g':'2','j':'2','I':'2',
        'Z':'3','z':'3','M':'3','R':'3',
        'p':'4','t':'4','o':'4',
        'k':'5','A':'5','J':'5',
        'C':'6','c':'6','N':'6','i':'6',
        'm':'7','n':'7','e':'7',
        'h':'8','B':'8','K':'8','L':'8',
        'S':'9','s':'9','O':'9','u':'9',
        'f':'0','l':'0','E':'0',
        'r':'v','P':'v','v':'v',
    }
    return ''.join(digit[c] for c in s)

def sentence_to_keys(pinyin):
    return ''.join(syl_to_keys(s) for s in pinyin.split())

TESTS = [
    ('好像有比較厲害', 'hao3 xiang4 you3 bi3 jiao4 li4 hai4'),
    ('今天天氣很好',   'jin1 tian1 tian1 qi4 hen3 hao3'),
    ('我等一下要去開會', 'wo3 deng3 yi1 xia4 yao4 qu4 kai1 hui4'),
    ('明天早上十點見面', 'ming2 tian1 zao3 shang4 shi2 dian3 jian4 mian4'),
    ('這個東西真的很好用', 'zhe4 ge4 dong1 xi1 zhen1 de5 hen3 hao3 yong4'),
    ('不知道你在說什麼', 'bu4 zhi1 dao4 ni3 zai4 shuo1 shen2 me5'),
    ('幫我買一杯咖啡',  'bang1 wo3 mai3 yi1 bei1 ka1 fei1'),
    ('已經到家了',      'yi3 jing1 dao4 jia1 le5'),
    ('等一下打給你',    'deng3 yi1 xia4 da3 gei3 ni3'),
    ('晚餐想吃什麼',    'wan3 can1 xiang3 chi1 shen2 me5'),
]

if __name__ == '__main__':
    for text, py in TESTS:
        print(f'{sentence_to_keys(py)}\t{text}')

TONE_KEY = {'1': 'q', '2': 'w', '3': 'x', '4': 'y', '5': ''}

def syl_to_keys_toned(syl):
    m = __import__('re').search(r'([1-5])$', syl)
    tone = TONE_KEY[m.group(1)] if m else ''
    return syl_to_keys(syl) + tone

def sentence_to_keys_toned(pinyin):
    return ''.join(syl_to_keys_toned(s) for s in pinyin.split())
