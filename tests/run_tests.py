# bopomofo_t9 迴歸測試套件
#
# 用法：
#   python tests/setup_bench.py   # 第一次先下載相依
#   python tests/run_tests.py     # 跑全部測試，失敗時 exit code != 0
#
# 測試內容：
#   1. 字典格式靜態檢查（Tab 分隔、無編碼失敗）
#   2. 關鍵字詞排名（吃、好欸、台股、emoji、救回詞條）
#   3. 長句整句猜測迴歸（10 句帶聲調，8 句應全對、2 句已知失敗）
#   4. 自動聯想學習循環（上屏 → 學習 → 聯想）
import io
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

TESTS_DIR = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(TESTS_DIR)
sys.path.insert(0, TESTS_DIR)

import bench
import py2t9

PASS, FAIL, XFAIL = [], [], []


def check(name, ok, detail=''):
    tag = 'PASS' if ok else 'FAIL'
    (PASS if ok else FAIL).append(name)
    print(f'[{tag}] {name}' + (f'  ({detail})' if detail else ''))


def rank_of(results, target):
    for i, t in enumerate(results):
        if t == target:
            return i
    return None


# ---------- 1. 字典靜態檢查 ----------
def static_checks():
    print('== 字典靜態檢查 ==')
    dict_path = os.path.join(REPO, 'bopomofo_t9', 'bopomofo_t9.dict.yaml')
    body = False
    bad_space = []
    for ln, l in enumerate(io.open(dict_path, encoding='utf-8'), 1):
        l = l.rstrip('\n')
        if l == '...':
            body = True
            continue
        if not body or not l or l.startswith('#'):
            continue
        if '\t' not in l and re.match(r'^[^\x00-\x7f]+ [a-z]+[0-9]', l):
            bad_space.append(ln)
    check('詞條無空格分隔（must use Tab）', not bad_space,
          f'{len(bad_space)} 行' if bad_space else '')


# ---------- 2. 關鍵字詞排名 ----------
RANK_CASES = [
    # (鍵序, 目標, 容許最差名次, 說明)
    ('Cq',     '吃',   1,  '精確 ㄔˉ'),
    ('6q',     '吃',   5,  'T9 鍵 6+ˉ'),
    ('88x5y',  '好欸', 1,  '救回的口語詞'),
    ('42w29x', '台股', 1,  '救回的投資詞'),
    ('9895',   '稍微', 5,  '救回的 655 行詞條'),
    ('4293',   '🇹🇼',  5,  'emoji 純數字鍵碼'),
    ('v16',    '🇯🇵',  3,  'emoji 含 v 鍵碼'),
    ('96w77',  '什麼', 3,  '什 shen2 讀音修正'),
]


def rank_checks():
    print('== 關鍵字詞排名 ==')
    for keys, target, worst, why in RANK_CASES:
        results, _ = bench.test_input(keys, quiet=True)
        r = rank_of(results, target)
        ok = r is not None and r < worst
        check(f'{keys} → {target} 前 {worst} 名（{why}）', ok,
              f'實際第 {r + 1} 名' if r is not None else '不在候選中')


# ---------- 3. 長句整句猜測迴歸 ----------
# known_fail=True 的句子是已知未解案例（單鍵簡拼路徑搶權重），
# 修好後請把它改成 False 並慶祝。
SENTENCE_CASES = [
    ('好像有比較厲害',   'hao3 xiang4 you3 bi3 jiao4 li4 hai4',  False),
    ('今天天氣很好',     'jin1 tian1 tian1 qi4 hen3 hao3',        False),
    ('我等一下要去開會', 'wo3 deng3 yi1 xia4 yao4 qu4 kai1 hui4', False),
    ('明天早上十點見面', 'ming2 tian1 zao3 shang4 shi2 dian3 jian4 mian4', False),
    ('這個東西真的很好用', 'zhe4 ge4 dong1 xi1 zhen1 de5 hen3 hao3 yong4', False),
    ('不知道你在說什麼', 'bu4 zhi1 dao4 ni3 zai4 shuo1 shen2 me5', False),
    ('幫我買一杯咖啡',   'bang1 wo3 mai3 yi1 bei1 ka1 fei1',      True),
    ('已經到家了',       'yi3 jing1 dao4 jia1 le5',               False),
    ('等一下打給你',     'deng3 yi1 xia4 da3 gei3 ni3',           False),
    ('晚餐想吃什麼',     'wan3 can1 xiang3 chi1 shen2 me5',       True),
]


def sentence_checks():
    print('== 長句整句猜測（帶聲調，首選須全對）==')
    for text, py, known_fail in SENTENCE_CASES:
        keys = py2t9.sentence_to_keys_toned(py)
        results, _ = bench.test_input(keys, quiet=True)
        first = results[0] if results else ''
        ok = first == text
        if known_fail:
            tag = 'XPASS!' if ok else 'xfail'
            (PASS if ok else XFAIL).append(text)
            print(f'[{tag}] {text}' + ('' if ok else f'  (首選: {first})'))
        else:
            check(text, ok, '' if ok else f'首選: {first}')


# ---------- 4. 自動聯想學習循環 ----------
def prediction_checks():
    print('== 自動聯想（須放最後：會寫入使用者詞典）==')
    _, c1 = bench.test_input('94x{space}', quiet=True)   # 我
    _, c2 = bench.test_input('83x{space}', quiet=True)   # 廠（學習 我→廠）
    results, c3 = bench.test_input('94x{space}', quiet=True)
    ok = (c1 == '我' and c3 == '我' and c2 and
          results and results[0] == c2)
    check('上屏學習 → 聯想出現', ok,
          f'commits: {c1},{c2},{c3}; 聯想: {results[:3]}')


# ---------- 5. 部署 log 檢查 ----------
def log_checks():
    print('== 部署 log ==')
    log = bench.deploy_log()
    e_failures = [l for l in log.splitlines()
                  if l.startswith('E') and 'Encode failure' in l]
    check('字典編譯無 E 級 Encode failure', not e_failures,
          f'{len(e_failures)} 個' if e_failures else '')


def main():
    static_checks()
    bench.init()
    rank_checks()
    sentence_checks()
    log_checks()
    prediction_checks()   # 最後跑（會污染使用者詞典狀態）

    print()
    print(f'結果: {len(PASS)} pass, {len(FAIL)} fail, {len(XFAIL)} xfail(已知)')
    sys.exit(1 if FAIL else 0)


if __name__ == '__main__':
    main()
