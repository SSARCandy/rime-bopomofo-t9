# RIME T9 Bopomofo Project

Custom RIME input method schema for T9 (3x4) Bopomofo layout, deployed via **元書輸入法 (Hamster3)** on iOS.

## Project Overview
- **Type**: RIME Input Method Schema + keyboard skin + regression tests
- **Target Layout**: T9 (3x4) numeric grid for Traditional Chinese (Bopomofo/注音).
- **Client**: 元書輸入法 (App Store id6744464701, librime-based). The predecessor Hamster (倉輸入法) is deprecated; legacy notes live in README's collapsed section.

## Repository Layout
- `bopomofo_t9/` — the RIME schema folder, shaped exactly as 元書's `RimeUserData/bopomofo_t9/`. Zip this folder and open with 元書 to install. Contains:
  - `bopomofo_t9.schema.yaml` — schema: spelling algebra, tone handling, grammar model config, prediction wiring.
  - `bopomofo_t9.dict.yaml` — dictionary (Traditional Chinese, tone-annotated readings, T9 digit-code emoji entries).
  - `rime.lua` — smart candidate sorting filter (v16): full-coverage candidates (sentence guess) first, then best candidate per coverage length round-robin, orphan-tone candidates demoted.
  - `lua/wanxiang/` — self-learning next-word prediction (from wanxiang project; pure librime-lua, no plugin needed). `user_predict.lua` is forked with `env.is_t9 = true` hardcoded.
  - Two large files are downloaded, not committed: `essay.txt` (preset vocabulary — critical for sentence composition quality) and `zh-hant-t-essay-bgw.gram` (octagram grammar model).
- `yuanshu-skin/` — 元書 keyboard skin source (jsonnet, forked from kongshan-suying which has no license — ask author before public redistribution). `config.yaml`/`light/`/`dark/` are build products (gitignored). Package: wrap contents in one top-level folder, zip, rename `.cskin`.
- `tests/` — regression bench: drives the real librime 1.17.0 engine (same version/plugins as 元書) via ctypes. `python tests/setup_bench.py` once, then `python tests/run_tests.py`. Ad-hoc query: `python tests/bench.py "6q=吃"`.

## Development Conventions

### Tone Keys
Tone marks map to letters unused by any Bopomofo code:
- **ˉ**: `q` **ˊ**: `w` **ˇ**: `x` **ˋ**: `y`
- Tone 5 (輕聲): no key; algebra strips trailing `5` from dictionary codes, so neutral-tone syllables are typed toneless.

### Key Mapping (T9 fuzzy groups)
1. `ㄅㄉㄚ`→`1` (b,d,a) 2. `ㄍㄐㄞ`→`2` (g,j,I) 3. `ㄓㄗㄢㄦ`→`3` (Z,z,M,R)
4. `ㄆㄊㄛ`→`4` (p,t,o) 5. `ㄎㄑㄟ`→`5` (k,A,J) 6. `ㄔㄘㄣㄧ`→`6` (C,c,N,i)
7. `ㄇㄋㄜ`→`7` (m,n,e) 8. `ㄏㄒㄠㄡ`→`8` (h,B,K,L) 9. `ㄕㄙㄤㄨ`→`9` (S,s,O,u)
10. `ㄈㄌㄝ`→`0` (f,l,E) 11. `ㄖㄥㄩ`→`v` (r,P,v)

Long-press callouts send the precise ASCII letter (e.g. `Z` for ㄓ) for exact filtering; plain taps send the ambiguous digit. Case-sensitivity is exploited (`S`=ㄕ vs `s`=ㄙ). Medials/finals precise codes use uppercase letters (I,J,K,L,M,N,O,P,R,E) per the table above.

### Dictionary Weight Mechanics (hard-won lessons)
- Entries without an explicit weight column get their weight from `essay.txt` preset-vocabulary lookup. **Words absent from essay get near-zero weight and are buried** — colloquial/Taiwan-tech/finance words needed an explicit floor weight (10000).
- A single-char reading with percentage **below 5% is excluded from word encoding** (librime threshold) — e.g. `什 shen2 1%` silently caused essay's 什麼-family to be indexed under shi2. Keep legitimate word-forming readings ≥5%.
- essay is a formal corpus: colloquial chars/words (吃 805!) are undervalued; fix with explicit weights.
- Dictionary body lines MUST be Tab-separated (`word<TAB>codes`); space-separated lines are silently dropped at deploy (E-level "Encode failure" in log).
- Word readings use citation tones, not sandhi: 一下 = `yi1 xia4` (not yi2).

### Long-Phrase & Accuracy
- Sentence composition (Poet) is built into `script_translator`; `enable_sentence`/`enable_encoder`/`encode_commit_history`/`max_phrase_length` are table_translator-only (no effect here).
- **Grammar model enabled by default** (`grammar: language: zh-hant-t-essay-bgw` + `contextual_suggestions: true`, `max_homophones: 7`). Measured: essay vocabulary matters far more than which .gram (wanxiang LTS 421MB gave only marginal gains over 八股文 10.5MB — not adopted).
- **Prediction**: 元書's librime lacks the librime-predict plugin; prediction is implemented via wanxiang's `user_predict.lua` (learns from commits into `predict.userdb`; placeholder char `›` must be in speller alphabet/initials).
- `derive/^(.).+$/$1/` single-key shorthand is the main ambiguity source but is a core user habit — keep.

## Building and Usage
1. Download `essay.txt` + `zh-hant-t-essay-bgw.gram` into `bopomofo_t9/`.
2. Zip the `bopomofo_t9/` folder (UTF-8), open with 元書 → auto-imports to `RimeUserData/bopomofo_t9/`.
3. 元書 輸入方案 page → `…` → 方案目錄切換 → `bopomofo_t9` → redeploy → select 注音九宮格.
4. Skin: package `yuanshu-skin/` as `.cskin` (see its README), import, select.
5. After any schema/dict/lua change, run `python tests/run_tests.py` before shipping.
