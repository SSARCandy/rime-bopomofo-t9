// 此精簡版皮膚僅保留 T9 數字九宮格佈局。
// 其餘佈局（9/row/hex）的框架檔已移除，
// 需要時可從上游 kongshan-suying 取回並還原此處的分派邏輯。
local numericT9 = import './Numeric/NumericT9.libsonnet';

{
  new(isDark, isPortrait):
    numericT9.new(isDark, isPortrait),
}
