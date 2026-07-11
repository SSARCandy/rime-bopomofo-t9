# RIME T9 注音九宮格方案

<p align="center">
  <img src="demo/demo.gif" width="30%" />
  <img src="demo/demo-t9.png" width="30%" />
  <img src="demo/demo-numpad.png" width="30%" />
</p>

本項目為 RIME 輸入法引擎量身打造的 T9 (3x4) 九宮格注音輸入方案，特別針對 iOS 上的 **倉輸入法 (Hamster)** 進行了深度優化。

## 🌟 特色功能

- **九宮格佈局**：符合傳統手機使用習慣的注音九宮格排列。
- **純淨繁體字**：內建全繁體高權重字典，無須繁簡轉換器拖慢效能。
- **精確選注音**：長按即可選擇精確注音，實現「所選即所得」。
- **快捷標點號**：空白鍵長按可快速輸入 `，` `。` `？` `！`。
- **獨立聲調鍵**：獨立聲調鍵（ˉ ˊ ˇ ˋ），支援精確過濾。
- **有數字鍵盤**：可以快速切換成九宮格數字鍵盤。

## 🛠️ 安裝步驟

### 1. 準備工具
- 在 iOS 設備上安裝 [倉輸入法 (Hamster)](https://apps.apple.com/app/id6446617683)。
- 下載本倉庫的所有檔案：
  - `bopomofo_t9.schema.yaml` (RIME 方案)
  - `bopomofo_t9.dict.yaml` (字典檔)
  - `t9bopomo.yaml` (鍵盤佈局檔)
  - `rime.lua` (智慧排序腳本)

### 2. 部署檔案
將本倉庫的所有檔案（`*.yaml` 與 `rime.lua`）放入 Hamster 的 RIME 用戶目錄中

### 3. 部署鍵盤佈局 (`t9bopomo.yaml`)
1. 將 `t9bopomo.yaml` 上傳至 Hamster 的 RIME 目錄。
2. 在 Hamster App 中進入 ***鍵盤佈局**。
3. 導入或確保佈局文件已正確啟用。

### 4. 生效設定
1. 在 Hamster App 首頁點擊 **RIME** -> **重新部署**。
2. 在 Hamster App 中進入 ***輸入方案設定** -> 選擇 **注音九宮格**。

## 🚀 進階：啟用語法模型（強烈建議）

長句自動斷詞的品質可以透過 n-gram 語法模型大幅提升（Hamster 內建 octagram 插件）：

1. 下載繁體八股文詞語模型 [`zh-hant-t-essay-bgw.gram`](https://github.com/lotem/rime-octagram-data/raw/hant/zh-hant-t-essay-bgw.gram)（約 10.5 MB）。
2. 將 `.gram` 檔放入 Hamster 的 RIME 使用者目錄（與 schema 同層）。
3. 打開 `bopomofo_t9.schema.yaml`，取消 `grammar:` 區塊以及 `contextual_suggestions`、`max_homophones` 兩行的註解。
4. 重新部署。

## 💡 長句輸入技巧

- 打完整串注音後，若整句猜測不對，直接從候選列挑出正確的**第一段**（候選列前端會輪流出現各種長度的首段選擇），選完 RIME 會對剩餘輸入繼續出候選，一段一段選完自動上屏。
- **在同一次輸入內分段選完**（不要分次上屏），RIME 會把整句記進使用者詞典——下次輸入同樣的編碼，整句會直接出現。
- 多打聲調：聲調鍵同時是「精確過濾」與「斷詞錨點」，斷錯位置的候選會被自動壓到最後。


## 🔗 相關連結
- [Hamster GitHub](https://github.com/imfuxiao/Hamster)
- [RIME 官網](https://rime.im/)
