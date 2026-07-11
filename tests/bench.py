# librime 測試台：載入 repo 的 bopomofo_t9 方案，模擬按鍵並列出候選
#
# 用法（先跑 python tests/setup_bench.py 下載相依）：
#   python tests/bench.py "6q=吃"          查「吃」在鍵序 6q 的候選排名
#   python tests/bench.py "94x{space}"     模擬上屏（{space} 等按鍵名可用）
#
# 每次執行都會把 repo 根目錄的 schema/dict/rime.lua/lua/ 複製到 tests/workdir
# 重新部署——測的永遠是 repo 目前的檔案。
import ctypes
import io
import os
import shutil
import sys

sys.stdout.reconfigure(encoding='utf-8')

TESTS_DIR = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(TESTS_DIR)
DEPS = os.path.join(TESTS_DIR, 'deps')
WORKDIR = os.path.join(TESTS_DIR, 'workdir')
DLL = os.path.join(DEPS, 'librime', 'dist', 'lib', 'rime.dll')

DEFAULT_YAML = '''config_version: "1.0"
schema_list:
  - schema: bopomofo_t9
menu:
  page_size: 9
key_binder:
  bindings: []
switcher:
  hotkeys: []
punctuator:
  full_shape: {}
  half_shape: {}
recognizer:
  patterns: {}
'''

Bool = ctypes.c_int
SessionId = ctypes.c_void_p


class RimeTraits(ctypes.Structure):
    _fields_ = [
        ('data_size', ctypes.c_int),
        ('shared_data_dir', ctypes.c_char_p),
        ('user_data_dir', ctypes.c_char_p),
        ('distribution_name', ctypes.c_char_p),
        ('distribution_code_name', ctypes.c_char_p),
        ('distribution_version', ctypes.c_char_p),
        ('app_name', ctypes.c_char_p),
        ('modules', ctypes.POINTER(ctypes.c_char_p)),
        ('min_log_level', ctypes.c_int),
        ('log_dir', ctypes.c_char_p),
        ('prebuilt_data_dir', ctypes.c_char_p),
        ('staging_dir', ctypes.c_char_p),
    ]


class RimeComposition(ctypes.Structure):
    _fields_ = [
        ('length', ctypes.c_int),
        ('cursor_pos', ctypes.c_int),
        ('sel_start', ctypes.c_int),
        ('sel_end', ctypes.c_int),
        ('preedit', ctypes.c_char_p),
    ]


class RimeCandidate(ctypes.Structure):
    _fields_ = [
        ('text', ctypes.c_char_p),
        ('comment', ctypes.c_char_p),
        ('reserved', ctypes.c_void_p),
    ]


class RimeMenu(ctypes.Structure):
    _fields_ = [
        ('page_size', ctypes.c_int),
        ('page_no', ctypes.c_int),
        ('is_last_page', ctypes.c_int),
        ('highlighted_candidate_index', ctypes.c_int),
        ('num_candidates', ctypes.c_int),
        ('candidates', ctypes.POINTER(RimeCandidate)),
        ('select_keys', ctypes.c_char_p),
    ]


class RimeContext(ctypes.Structure):
    _fields_ = [
        ('data_size', ctypes.c_int),
        ('composition', RimeComposition),
        ('menu', RimeMenu),
        ('commit_text_preview', ctypes.c_char_p),
        ('select_labels', ctypes.POINTER(ctypes.c_char_p)),
    ]


class RimeCandidateListIterator(ctypes.Structure):
    _fields_ = [
        ('ptr', ctypes.c_void_p),
        ('index', ctypes.c_int),
        ('candidate', RimeCandidate),
    ]


class RimeCommit(ctypes.Structure):
    _fields_ = [
        ('data_size', ctypes.c_int),
        ('text', ctypes.c_char_p),
    ]


rime = None
session = None


def _bind(lib):
    lib.RimeSetup.argtypes = [ctypes.POINTER(RimeTraits)]
    lib.RimeInitialize.argtypes = [ctypes.POINTER(RimeTraits)]
    lib.RimeStartMaintenance.argtypes = [Bool]
    lib.RimeStartMaintenance.restype = Bool
    lib.RimeCreateSession.restype = SessionId
    lib.RimeSelectSchema.argtypes = [SessionId, ctypes.c_char_p]
    lib.RimeSelectSchema.restype = Bool
    lib.RimeSimulateKeySequence.argtypes = [SessionId, ctypes.c_char_p]
    lib.RimeSimulateKeySequence.restype = Bool
    lib.RimeClearComposition.argtypes = [SessionId]
    lib.RimeCandidateListBegin.argtypes = [SessionId, ctypes.POINTER(RimeCandidateListIterator)]
    lib.RimeCandidateListBegin.restype = Bool
    lib.RimeCandidateListNext.argtypes = [ctypes.POINTER(RimeCandidateListIterator)]
    lib.RimeCandidateListNext.restype = Bool
    lib.RimeCandidateListEnd.argtypes = [ctypes.POINTER(RimeCandidateListIterator)]
    lib.RimeGetContext.argtypes = [SessionId, ctypes.POINTER(RimeContext)]
    lib.RimeGetContext.restype = Bool
    lib.RimeFreeContext.argtypes = [ctypes.POINTER(RimeContext)]
    lib.RimeGetCommit.argtypes = [SessionId, ctypes.POINTER(RimeCommit)]
    lib.RimeGetCommit.restype = Bool
    lib.RimeFreeCommit.argtypes = [ctypes.POINTER(RimeCommit)]


def assemble_workdir():
    """從 repo 根目錄組裝乾淨的 RIME 使用者目錄"""
    if os.path.exists(WORKDIR):
        shutil.rmtree(WORKDIR)
    os.makedirs(os.path.join(WORKDIR, 'log'))
    schema_dir = os.path.join(REPO, 'bopomofo_t9')
    for f in ['bopomofo_t9.schema.yaml', 'bopomofo_t9.dict.yaml', 'rime.lua']:
        shutil.copy(os.path.join(schema_dir, f), WORKDIR)
    shutil.copytree(os.path.join(schema_dir, 'lua'), os.path.join(WORKDIR, 'lua'))
    for f in ['essay.txt', 'zh-hant-t-essay-bgw.gram']:
        shutil.copy(os.path.join(DEPS, f), WORKDIR)
    with io.open(os.path.join(WORKDIR, 'default.yaml'), 'w',
                 encoding='utf-8', newline='\n') as fh:
        fh.write(DEFAULT_YAML)


def init():
    """組裝 workdir、部署、開 session。回傳前所有測試共用同一個引擎。"""
    global rime, session
    if session is not None:
        return
    if not os.path.exists(DLL):
        sys.exit('找不到 rime.dll，請先執行: python tests/setup_bench.py')
    assemble_workdir()

    rime = ctypes.CDLL(DLL)
    _bind(rime)

    traits = RimeTraits()
    traits.data_size = ctypes.sizeof(RimeTraits) - ctypes.sizeof(ctypes.c_int)
    traits.shared_data_dir = WORKDIR.encode()
    traits.user_data_dir = WORKDIR.encode()
    traits.distribution_name = b'bench'
    # 偽裝行動端，讓 wanxiang user_predict 走「上屏後聯想」模式（與手機一致）
    traits.distribution_code_name = b'hamster3'
    traits.distribution_version = b'1.0'
    traits.app_name = b'rime.bench'
    traits.min_log_level = 0
    traits.log_dir = os.path.join(WORKDIR, 'log').encode()
    traits.staging_dir = os.path.join(WORKDIR, 'build').encode()

    rime.RimeSetup(ctypes.byref(traits))
    rime.RimeInitialize(ctypes.byref(traits))
    if rime.RimeStartMaintenance(1):
        rime.RimeJoinMaintenanceThread()

    session = rime.RimeCreateSession()
    if not rime.RimeSelectSchema(session, b'bopomofo_t9'):
        sys.exit('無法選用 bopomofo_t9 方案（部署失敗？看 tests/workdir/log）')


def test_input(keys, find=None, show=30, quiet=False):
    """模擬按鍵，回傳 (候選列表, 上屏文字)"""
    init()
    rime.RimeClearComposition(session)
    rime.RimeSimulateKeySequence(session, keys.encode())

    commit = RimeCommit()
    commit.data_size = ctypes.sizeof(RimeCommit) - ctypes.sizeof(ctypes.c_int)
    committed = ''
    if rime.RimeGetCommit(session, ctypes.byref(commit)):
        committed = commit.text.decode('utf-8', 'replace') if commit.text else ''
        rime.RimeFreeCommit(ctypes.byref(commit))

    ctx = RimeContext()
    ctx.data_size = ctypes.sizeof(RimeContext) - ctypes.sizeof(ctypes.c_int)
    rime.RimeGetContext(session, ctypes.byref(ctx))
    preedit = ctx.composition.preedit.decode('utf-8', 'replace') if ctx.composition.preedit else ''
    rime.RimeFreeContext(ctypes.byref(ctx))

    it = RimeCandidateListIterator()
    results = []
    if rime.RimeCandidateListBegin(session, ctypes.byref(it)):
        while rime.RimeCandidateListNext(ctypes.byref(it)):
            results.append(it.candidate.text.decode('utf-8', 'replace'))
            if len(results) > 3000:
                break
        rime.RimeCandidateListEnd(ctypes.byref(it))

    if not quiet:
        print(f'--- input: {keys}  (preedit: {preedit})  (committed: {committed}) ---')
        print(f'total candidates: {len(results)}')
        print('first:', ' | '.join(results[:show]))
        if find:
            for target in find:
                pos = [i for i, t in enumerate(results) if target in t]
                print(f'find {target}: positions {pos[:5] if pos else "NOT FOUND"}')
    return results, committed


def deploy_log():
    """回傳部署 INFO log 內容（除錯用）"""
    logdir = os.path.join(WORKDIR, 'log')
    logs = sorted(f for f in os.listdir(logdir) if '.INFO.' in f)
    if not logs:
        return ''
    return io.open(os.path.join(logdir, logs[-1]), encoding='utf-8',
                   errors='replace').read()


if __name__ == '__main__':
    for arg in sys.argv[1:]:
        if '=' in arg:
            keys, targets = arg.split('=', 1)
            test_input(keys, find=targets.split(','))
        else:
            test_input(arg)
