# RIME T9 Bopomofo Project

Custom RIME input method schema for T9 (3x4) Bopomofo layout, specifically optimized for mobile devices or numeric keypads.

## Project Overview
- **Type**: RIME Input Method Schema
- **Target Layout**: T9 (3x4) numeric grid for Traditional Chinese (Bopomofo/注音).
- **Core Technology**: RIME (Squirrel/Weasel/Trime) schema engine.
- **Dictionary**: Based on `terra_pinyin` (Earth Pinyin) with tone support.

## Key Files
- `bopomofo_t9.schema.yaml`: The main RIME schema definition containing spelling algebra and engine configuration.
- `t9bopomo.yaml`: Keyboard layout definition (likely for Trime/OpenBangla or similar mobile RIME clients).
- `terra_pinyin.dict.yaml`: The source dictionary providing characters and their pinyin/bopomofo readings.

## Development Conventions

### Tone Filtering
The schema uses specific lowercase ASCII characters to map Bopomofo tone marks, specifically chosen to avoid any conflicts with Bopomofo-to-numeric key mappings:
- **Tone 2 (ˊ)**: Mapped to `w`
- **Tone 3 (ˇ)**: Mapped to `y`
- **Tone 4 (ˋ)**: Mapped to `q`
- **Tone 5 (˙)**: Mapped to `p`
- **Tone 1**: Implicit/No mark.

### Key Mapping Logic
The `speller/algebra` in the schema file maps Bopomofo symbols to numeric keys:
1. `ㄅㄉㄚ` -> `1`
2. `ㄍㄐㄞ` -> `2`
3. `ㄓㄗㄢㄦ` -> `3`
4. `ㄆㄊㄛ` -> `4`
5. `ㄎㄑㄟ` -> `5`
6. `ㄔㄘㄣㄧ` -> `6`
7. `ㄇㄋㄜ` -> `7`
8. `ㄏㄒㄠㄡ` -> `8`
9. `ㄕㄙㄤㄨ` -> `9`
10. `ㄈㄌㄝ` -> `0`
11. `ㄖㄥㄩ` -> `v`

## Building and Usage
1. Copy `bopomofo_t9.schema.yaml` and `terra_pinyin.dict.yaml` to your RIME user directory.
2. Add `bopomofo_t9` to your `default.custom.yaml` under `schema_list`.
3. Deploy RIME.
4. For mobile (Trime), ensure `t9bopomo.yaml` is correctly referenced in your keyboard configuration.
