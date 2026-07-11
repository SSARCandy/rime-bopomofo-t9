# 迴歸測試台

在電腦上用**真實 librime 引擎**（與元書同版本 1.17.0、同插件組合 lua/octagram/predict）
載入 repo 的方案檔，模擬按鍵、檢查候選排名。改 schema／字典／rime.lua 之後跑一輪，
確保沒把打字體驗改壞。

## 使用

```bash
pip install py7zr              # 解壓 librime 用，只需一次
python tests/setup_bench.py    # 下載相依到 tests/deps/（librime、essay.txt、.gram，約 30MB）
python tests/run_tests.py      # 跑全部測試；有 FAIL 時 exit code = 1
```

臨時查詢單一鍵序（開發時最常用）：

```bash
python tests/bench.py "6q=吃"        # 「吃」在 ㄔˉ 的候選裡排第幾
python tests/bench.py "88x5y=好欸"   # 支援同時列出前 30 個候選
python tests/bench.py "94x{space}"   # {space} 等按鍵名可模擬上屏
```

## 檔案

| 檔案 | 用途 |
|---|---|
| `bench.py` | 引擎驅動器：組裝 workdir → 部署 → 模擬按鍵 → 迭代候選（ctypes 直呼 rime.dll） |
| `py2t9.py` | 拼音（字典讀音格式）→ T9 鍵序轉換器，重現 schema 的 speller/algebra |
| `run_tests.py` | 測試套件：字典靜態檢查、關鍵字詞排名、長句整句猜測、聯想學習循環、部署 log |
| `setup_bench.py` | 下載 librime／essay.txt／語法模型到 `tests/deps/`（gitignored） |

## 注意事項

- 每次執行都會把 `bopomofo_t9/` 的檔案複製到 `tests/workdir/`（gitignored）重新部署，
  測的永遠是 repo 目前的檔案；部署 log 在 `tests/workdir/log/`。
- 測試台是冷啟動（無使用者詞典），排名會比實機「未學習前」的狀態嚴格；
  實機上 userdb 會再往上調。
- `run_tests.py` 裡標 `known_fail` 的句子是已知未解案例，修好後改成 `False`。
- 編碼測試句時注意：字典詞條的「一」一律為一聲（一下 = `yi1 xia4`），
  不是口語變調的 yi2。
